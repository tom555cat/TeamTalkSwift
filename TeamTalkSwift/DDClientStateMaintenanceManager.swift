//
//  DDClientStateMaintenanceManager.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/11.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

let DD_USER_STATE_KEYPATH = "userState"
let DD_NETWORK_STATE_KEYPATH = "networkState"
let DD_SOCKET_STATE_KEYPATH = "socketState"
let DD_USER_ID_KEYPATH = "userID"

let heartBeatTimeinterval = 10
let serverHeartBeatTimeinterval = 60
let reloginTimeinterval = 5

class DDClientStateMaintenanceManager: NSObject {
    
    override init() {
        super.init()
        self.p_registerClientStateObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(n_receiveServerHeartBeat), name: DDNotificationServerHeartBeat, object: nil)
    }
    
    deinit {
        DDClientState.sharedInstance.removeObserver(self, forKeyPath: DD_NETWORK_STATE_KEYPATH, context: nil)
        DDClientState.sharedInstance.removeObserver(self, forKeyPath: DD_USER_STATE_KEYPATH, context: nil)
        NotificationCenter.default.removeObserver(self, name: DDNotificationServerHeartBeat, object: nil)
    }
    
    func n_receiveServerHeartBeat() {
        self.receiveServerHeart = true
    }
    
    func p_registerClientStateObserver() {
        
        // 网络状态
        DDClientState.sharedInstance.addObserver(self, forKeyPath: DD_NETWORK_STATE_KEYPATH, options:[.new, .old], context: nil)
        
        // 用户状态
        DDClientState.sharedInstance.addObserver(self, forKeyPath: DD_USER_STATE_KEYPATH, options: [.new, .old], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let clientState = DDClientState.sharedInstance
        
        if keyPath == DD_NETWORK_STATE_KEYPATH {
            // 网络状态变化
            if DDClientState.sharedInstance.networkState != .DDNetWorkDisconnect {
                
            } else {
                clientState.userState = .DDUserOffLine
                // [RecentUsersViewController shareInstance].title=@"连接失败";
            }
        } else if keyPath == DD_USER_STATE_KEYPATH {
            // 用户状态变化
            switch DDClientState.sharedInstance.userState {
            case .DDUserKickout:
                // [RecentUsersViewController shareInstance].title=@"未连接";
                self.p_stopCheckServerHeartBeat()
                self.p_stopHeartBeat()
            case .DDUserOffLine:
                // [RecentUsersViewController shareInstance].title=@"未连接";
                self.p_stopCheckServerHeartBeat()
                self.p_stopHeartBeat()
                self.p_startRelogin()
            case .DDUserOffLineInitiative:
                // [RecentUsersViewController shareInstance].title=@"未连接";
                self.p_stopCheckServerHeartBeat()
                self.p_stopHeartBeat()
            case .DDUserOnline:
                // [RecentUsersViewController shareInstance].title=APP_NAME;
                self.p_startCheckServerHeartBeat()
                self.p_startHeartBeat()
            case .DDUserLogining: break
                // [RecentUsersViewController shareInstance].title=@"收取中";
            }
        }
    }
    
    // 开启发送心跳的Timer
    func p_startHeartBeat() {
        
        DDLog("begin heart beat")
        
        // if self.sendHeartTimer == nil && self.sendHeartTimer?.isValid == false {   2017.3.7 仝磊鸣修改
        if self.sendHeartTimer == nil {
            self.sendHeartTimer = Timer.scheduledTimer(timeInterval: TimeInterval(heartBeatTimeinterval), target: self, selector: #selector(p_onSendHeartBeatTimer(timer:)), userInfo: nil, repeats: true)
        } else {
            if self.sendHeartTimer?.isValid == false {
                self.sendHeartTimer = Timer.scheduledTimer(timeInterval: TimeInterval(heartBeatTimeinterval), target: self, selector: #selector(p_onSendHeartBeatTimer(timer:)), userInfo: nil, repeats: true)
            }
        }
    }
    
    // 运行在发送心跳的Timer上
    func p_onSendHeartBeatTimer(timer: Timer) {
        DDLog("*********嘣*********")
        let heartbeatAPI = HeartbeatAPI()
        heartbeatAPI.requestWithObject(object: []) { (response: Any?, error: NSError?) in
            // 什么都不做
        }
    }
    
    // 开启检验服务器心跳的Timer
    func p_startCheckServerHeartBeat() {
        if self.serverHeartBeatTimer == nil {
            DDLog("begin maintenance _serverHeartBeatTimer")
            self.serverHeartBeatTimer = Timer.scheduledTimer(timeInterval: TimeInterval(serverHeartBeatTimeinterval), target: self, selector: #selector(p_onCheckServerHeartTimer(timer:)), userInfo: nil, repeats: true)
        }
    }
    
    // 运行在检验服务器端心跳的Timer上
    func p_onCheckServerHeartTimer(timer: Timer) {
        if self.receiveServerHeart {
            self.receiveServerHeart = false
        } else {
            self.serverHeartBeatTimer?.invalidate()
            self.serverHeartBeatTimer = nil
            DDLog("太久没有收到服务器端数据包了!")
            DDClientState.sharedInstance.userState = .DDUserOffLine
        }
    }
    
    // 开启重连Timer
    func p_startRelogin() {
        if self.reloginTimer == nil {
            self.reloginTimer = Timer.scheduledTimer(timeInterval: TimeInterval(reloginTimeinterval), target: self, selector: #selector(p_onReloginTimer(timer:)), userInfo: nil, repeats: true)
        }
    }
    
    // 运行在断线重连的Timer上
    func p_onReloginTimer(timer: Timer) {
        struct Holder {
            static var time: Int = 0
            static var powN: Int = 0
        }
        
        Holder.time += 1
        if Holder.time >= self.reloginInterval {
            LoginModule.sharedInstance.relogin(success: {
                self.reloginTimer?.invalidate()
                self.reloginTimer = nil
                Holder.time = 0
                Holder.powN = 0
                self.reloginInterval = 0
                // [RecentUsersViewController shareInstance].title=APP_NAME;
                NotificationCenter.default.post(name: DDNotificationUserReloginSuccess, object: nil, userInfo: nil)
                DDLog("重新登陆成功!")
            }, failure: { (error: String) in
                if error == "未登陆" {
                    self.reloginTimer?.invalidate()
                    self.reloginTimer = nil
                    Holder.time = 0
                    Holder.powN = 0
                    self.reloginInterval = 0
                    // [RecentUsersViewController shareInstance].title=APP_NAME;
                } else {
                    // [RecentUsersViewController shareInstance].title=@"未连接";
                    Holder.powN += 1
                    Holder.time = 0
                    self.reloginInterval = Int(pow(2.0, Double(Holder.powN)))
                }
            })
        }
        
    }
    
    // 停止检验服务器端心跳的Timer
    func p_stopCheckServerHeartBeat() {
        if self.serverHeartBeatTimer != nil {
            self.serverHeartBeatTimer?.invalidate()
            self.serverHeartBeatTimer = nil
        }
    }
    
    // 关闭发送心跳的Timer
    func p_stopHeartBeat() {
        if self.sendHeartTimer != nil {
            self.sendHeartTimer?.invalidate()
            self.sendHeartTimer = nil
        }
    }
    
    //MARK: Property
    var sendHeartTimer: Timer?
    var reloginTimer: Timer?
    var serverHeartBeatTimer: Timer?
    
    var receiveServerHeart: Bool = false
    var reloginInterval: Int = 0
    
    static let sharedInstance = DDClientStateMaintenanceManager()
}
