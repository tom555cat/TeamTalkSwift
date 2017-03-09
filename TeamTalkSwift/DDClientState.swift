//
//  DDClientState.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/8.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

/**
 *  用户状态
 **/
@objc enum DDUserState: UInt16 {
    /**
     *  用户在线
     */
    case DDUserOnline
    /**
     *  用户被挤下线
     */
    case DDUserKickout
    /**
     *  用户离线
     */
    case DDUserOffLine
    /**
     *  用户主动下线
     */
    case DDUserOffLineInitiative
    /**
     *  用户正在连接
     */
    case DDUserLogining
}

/**
 *  客户端网络状态
 **/
@objc enum DDNetWorkState: UInt16 {
    /**
     *  wifi
     */
    case DDNetWorkWifi
    /**
     *  3G
     */
    case DDNetWork3G
    /**
     *  2G
     */
    case DDNetWork2G
    /**
     *  无网
     */
    case DDNetWorkDisconnect
}

/**
 *  Socket 连接状态
 **/
enum DDSocketState: UInt16 {
    /**
     *  Socket连接登录服务器
     */
    case DDSocketLinkLoginServer
    /**
     *  Socket连接消息服务器
     */
    case DDSocketLinkMessageServer
    /**
     *  Socket没有连接
     */
    case DDSocketDisconnect
}



class DDClientState: NSObject {
    
    var reachability: DDReachability
    
    dynamic var userState: DDUserState
    
    dynamic var networkState: DDNetWorkState
    
    var socketState: DDSocketState
    
    var userID: String
    
    static let sharedInstance = DDClientState()
    
    override init() {
        userState = DDUserState.DDUserOffLine
        socketState = DDSocketState.DDSocketDisconnect
        networkState = DDNetWorkState.DDNetWorkWifi   // OC版没有这一项
        reachability = DDReachability.forInternetConnection()
        reachability.startNotifier()
        userID = ""
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(n_receiveReachabilityChangedNotification(notification:)), name: NSNotification.Name.ddReachabilityChanged, object: nil)
    }
    
    func setUserStateWithoutObserver(userState: DDUserState) {
        self.userState = userState
    }
    
    @objc func n_receiveReachabilityChangedNotification(notification: Notification) {
        /*
        let reach = notification.object as? DDReachability
        let netWorkStatus = reach?.currentReachabilityStatus()
        switch netWorkStatus {
        case NetworkStatus.NotReachable:
            self.networkState = DDNetWorkState.DDNetWorkDisconnect
        case 2:
            self.networkState = DDNetWorkState.DDNetWorkWifi
        case 1:
            self.networkState = DDNetWorkState.DDNetWork3G
        default:
            <#code#>
        }
         */
    }
}
