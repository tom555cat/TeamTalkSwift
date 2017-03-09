//
//  DDTcpServer.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/4.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

typealias ClientSuccess = () -> Void

typealias ClientFailure = (Error?) -> Void

let timeoutInterval:Double = 10.0

class DDTcpServer
{
    private var success: ClientSuccess? = nil
    private var failure: ClientFailure? = nil
    private var connecting: Bool = false
    private var connectTimes: Int = 0
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(n_receiveTcpLinkConnectCompleteNotification(notification: )), name: DDNotificationTcpLinkConnectComplete, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(n_receiveTcpLinkConnectFailureNotification(notification:)), name: DDNotificationTcpLinkConnectFailure, object: nil)
    }
    
    func  loginTcpServer(ip: String,
                         port: Int,
                         success: @escaping () -> Void,
                         failure: @escaping (Error?) -> Void) -> Void
    {
        if !connecting {
            self.connectTimes += 1
            self.connecting = true
            self.success = success
            self.failure = failure
            DDTcpClientManager.sharedInstance.disconnect()
            DDTcpClientManager.sharedInstance.connect(ipAdr: ip, port: port, status: 1)
            
            // 超时处理
            let nowTimes = self.connectTimes
            DispatchQueue.main.asyncAfter(deadline: .now() + timeoutInterval, execute: {
                // 当连接到服务器时，connecting就设置为了false，所以if不会执行
                if self.connecting && nowTimes == self.connectTimes {
                    self.connecting = false
                    self.failure?(nil)
                }
            })
        }
    }
    
    // MARK: - Notification
    @objc func n_receiveTcpLinkConnectCompleteNotification(notification: Notification)
    {
        if self.connecting {
            self.connecting = false
            DispatchQueue.main.async {
                self.success!()
            }
        }
    }
    
    @objc func n_receiveTcpLinkConnectFailureNotification(notification: Notification)
    {
        if self.connecting {
            self.connecting = false
            DispatchQueue.main.async {
                self.failure!(nil)
            }
        }
    }
}
