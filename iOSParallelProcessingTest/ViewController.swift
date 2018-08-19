//
//  ViewController.swift
//  iOSParallelProcessingTest
//
//  Created by rokihiro on 2018/08/07.
//  Copyright © 2018年 rokihiro. All rights reserved.
//

import UIKit
import Dispatch
import Foundation

protocol VCProtocol {
    var operationCountLabel : UILabel! {get set}
}


class ViewController: UIViewController, VCProtocol {

    @IBOutlet weak var gcdCountLabel: UILabel!
    @IBOutlet weak var operationCountLabel: UILabel!
    let operationQueue:OperationQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // GCD (Grand Central Dispatch)
        //////////
        
        // キューをつくる。
        // DispatchQueue.global(qos: .default)などでもとより動いている並列dispatchキューを取得することも可能。
        let queue = DispatchQueue(label: "net.rokihiro.appname.uniq_key", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        // label:他のアプリと被らないようにDNSの逆から形式で名前をつける
        // qos:優先度
        // attributes: オプション、ここだと並列dispatch queueを指定
        // autoreleaseFrequency: releaseされるタイミング.inherit,never,workitem (https://developer.apple.com/documentation/dispatch/dispatchqueue/autoreleasefrequencyに詳細が書いてないが、きっと親を継承、消えない、実行終わったらだろう)
        // target: 親？これも書いてない
        
        
        queue.async {
            for i in 0...100{
                print("queue:"+String(i))
                Thread.sleep(forTimeInterval: 0.1)
                if i % 10 == 0 {
                    DispatchQueue.main.async {
                        self.gcdCountLabel.text = String(i)
                    }
                }
            }
        }
        

        // Operation,OperationQueue
        //////////
        
        // Operation protocolを継承して、mainをoverrideして動かす
        class TestOperation: Operation{
            let number: Int
            let controlVC: VCProtocol
            let operationName: String
            init(number: Int,controlVC : VCProtocol, name:String) {
                self.number = number
                self.controlVC = controlVC
                self.operationName = name
            }
            
            override func main() {
                for i in 0...number{
                    print("Operation:"+self.operationName+":"+String(i))
                    Thread.sleep(forTimeInterval: 0.1)
                    // キャンセルされた場合、true
                    if isCancelled {
                        return
                    }
                    if i % 10 == 0 {
                        OperationQueue.main.addOperation {
                            self.controlVC.operationCountLabel.text = self.operationName+":"+String(i)
                        }
                    }
                }
            }
        }
        
        // キューを作る
        // GCDと異なり、元から動いている並列dispatchキューはいない
        operationQueue.name = "net.rokihiro.appname.uniq_key1"
        operationQueue.maxConcurrentOperationCount = 3 // 並列数
        operationQueue.qualityOfService = .default
        
        
        let ope1 = TestOperation(number: 100,controlVC: self, name:"OP1")
        let ope2 = TestOperation(number: 100,controlVC: self, name:"OP2")
        // ope2はope1に依存するので、ope1の後に実行される
        ope2.addDependency(ope1)
        let prallelOpe = TestOperation(number: 100,controlVC: self, name:"OP-para")
        
        // waitUntilFinished: この処理が終わるまでスレッドの動きを止める。デッドロックを起こしうるので使わないほうが良い
        operationQueue.addOperations([ope1,ope2,prallelOpe], waitUntilFinished: false)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapCancelButton(_ sender: Any) {
        // OperationQueueはキャンセル可
        operationQueue.operations[0].cancel()
    }
}

