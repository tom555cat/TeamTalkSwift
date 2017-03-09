//
//  ViewController.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2016/12/29.
//  Copyright © 2016年 Hello World Corporation. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Hello World!")
        // Do any additional setup after loading the view, typically from a nib.
        let log = LoginModule.sharedInstance
        log.login(name: "test", password: "test", success: {_ in }, failure: {_ in })
        //let httpServer = DDHttpServer()
        //httpServer.getMsgIP(block: {_ in }, failure: {_ in })
        
        //let ip = "192.168.54.134"
        //let port = 8000
        //DDTcpClientManager.sharedInstance.disconnect()
        //DDTcpClientManager.sharedInstance.connect(ipAdr: ip, port: port, status: 1)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

