//
//  DDUserModule.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/7.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

typealias DDLoadRecentUsersCompletion = () -> Void

class DDUserModule {
    
    init() {
        
        self.allUsers = [String: Any]()
        self.recentUsers = [String: MTTUserEntity]()
        
        NotificationCenter.default.addObserver(self, selector: #selector(n_receiveUserLoginNotification(notification:)), name: DDNotificationUserLoginSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(n_receiveUserLoginNotification(notification:)), name: DDNotificationUserReloginSuccess, object: nil)
    }
    
    func addMaintanceUser(user: MTTUserEntity?) {
        if user == nil {
            return
        }
        if allUsers == nil {
            allUsers = [String: Any]()
        }
        if allUsersNick == nil {
            allUsersNick = [String: Any]()
        }
        allUsers?[(user?.objID)!] = user!
        allUsersNick?[(user?.nick)!] = user!
    }
    
    func getUserFor(userID: String, block: (MTTUserEntity)->Void) {
        return block(allUsers![userID] as! MTTUserEntity)
    }
    
    func addRecentUser(user: MTTUserEntity?) {
        if user == nil {
            return
        }
        if recentUsers == nil {
            recentUsers = [String: MTTUserEntity]()
        }
        let allKeys = Array((recentUsers?.keys)!)
        if !allKeys.contains((user?.objID)!) {
            recentUsers?[(user?.objID)!] = user
            MTTDatabaseUtil.sharedInstance.insertUsers(users: [user], completion: { (error: NSError?) in
                // 没有错误处理
            })
        }
    }
    
    func loadAllRecentUsers(completion: DDLoadRecentUsersCompletion) {
        // 加载本地最近联系人
    }
    
    func clearRecentUser() {
        DDUserModule.sharedInstance.recentUsers?.removeAll()
    }
    
    func getAllMaintenance() -> [Any] {
        return Array((allUsers?.values)!)
    }
    
    func getUserByNick(nickName: String) -> MTTUserEntity {
        return allUsersNick![nickName] as! MTTUserEntity
    }
    
    //MARK: Notification
    
    @objc private func n_receiveUserLogoutNotification(notification: Notification) {
        // 用户登出
        self.recentUsers = nil
    }
    
    @objc private func n_receiveUserLoginNotification(notification: Notification) {
        if recentUsers == nil {
            self.loadAllRecentUsers {
                MTTNotification.postNotification(notification: DDNotificationRecentContactsUpdate, userInfo: [:], object: nil)
            }
        }
    }
    
    static let sharedInstance = DDUserModule()
    var currentUserID: String = ""
    var recentUsers: Dictionary<String, MTTUserEntity>?
    
    private var allUsers: Dictionary<String, Any>?
    private var allUsersNick: Dictionary<String, Any>?
}
