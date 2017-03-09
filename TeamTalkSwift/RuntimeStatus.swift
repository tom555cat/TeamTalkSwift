//
//  RuntimeStatus.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/22.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class RuntimeStatus {
    
    init() {
        user = MTTUserEntity()
        self.registerAPI()
        self.checkUpdateVersion()
    }
    
    func updateData() {
        DDMessageModule.sharedInstance
        DDClientStateMaintenanceManager.sharedInstance
        DDGroupModule.sharedInstance
    }
    
    func checkUpdateVersion() {
        // 可以省略不写
    }
    
    func registerAPI() {
        // 接收踢出
        let receiveKick = ReceiveKickoffAPI()
        let res = receiveKick.registerAPIInAPIScheduleReceiveData(received: {(object: Any, error: NSError?) in
            NotificationCenter.default.post(name: DDNotificationUserKickouted, object: object)
        })
        if res == false {
            DDLog("注册接收踢出失败")
        }
        
        // 接收签名改变通知
        let receiveSignNotify = MTTSignNotifyAPI()
        let res1 = receiveSignNotify.registerAPIInAPIScheduleReceiveData { (object: Any, error: NSError?) in
            NotificationCenter.default.post(name: DDNotificationUserSignChanged, object: object)
        }
        if res1 == false {
            DDLog("注册签名改变失败")
        }
        
        // 接收pc端登陆状态变化通知
        let receivePCLoginNotify = MTTPCLoginStatusNotifyAPI()
        let res2 = receivePCLoginNotify.registerAPIInAPIScheduleReceiveData { (object: Any, error: NSError?) in
            NotificationCenter.default.post(name: DDNotificationPCLoginStatusChanged, object: object)
        }
        if res2 == false {
            DDLog("注册接收pc端登陆状态改变失败")
        }
    
    }
    
    static let sharedInstance = RuntimeStatus()
    var user: MTTUserEntity?
    var token: String?
    var userID: String?
    var pushToken: String?
    var updateInfo: [String: Any]?
}
