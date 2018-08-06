//
//  ViewController.swift
//  iOSParallelProcessingTest
//
//  Created by rokihiro on 2018/08/07.
//  Copyright © 2018年 rokihiro. All rights reserved.
//

import UIKit
import Dispatch

class ViewController: UIViewController {

    @IBOutlet weak var gcdCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let queue = DispatchQueue(label: "net.rokihiro.appname.uniq_key", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        // label:他のアプリと被らないようにDNSの逆から形式で名前をつける
        // qos:優先度
        // attributes: オプション、ここだと並列dispatch queueを指定
        // autoreleaseFrequency: releaseされるタイミング.inherit,never,workitem (https://developer.apple.com/documentation/dispatch/dispatchqueue/autoreleasefrequencyに詳細が書いてないが、きっと親を継承、消えない、実行終わったらだろう)
        // target: 親？これも書いてない
        
        
        queue.async {
            for i in 0...1000{
                print(i)
                Thread.sleep(forTimeInterval: 0.1)
                if i % 10 == 0 {
                    DispatchQueue.main.async {
                        self.gcdCountLabel.text = String(i)
                    }
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

