//
//  LoginModule.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/4.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class LoginModule {
    
    let httpServer: DDHttpServer = DDHttpServer()
    let tcpServer: DDTcpServer = DDTcpServer()
    let msgServer: DDMsgServer = DDMsgServer()
    
    func login(name: String,
               password: String,
               success: @escaping (MTTUserEntity) -> Void,
               failure: (Error) -> Void)
    {
        self.httpServer.getMsgIP(block: { (dic: NSDictionary) in
            let code = dic["code"] as! Int
            if code == 0 {
                let priorIP = dic["priorIP"] as? String
                let port = Int((dic["port"] as? String)!)
                MTTUtil.setMsfsUrl(url: dic.value(forKey: "msfsPrior") as! String)
                self.tcpServer.loginTcpServer(ip: priorIP!, port: port!, success: {
                    DDLog("连接TCP服务器成功")
                    self.msgServer.checkUser(userID: name, password: password, token: "", success: { (response: Any) in
                        DDLog("MsgServer Check Sucess!")
                        UserDefaults.standard.set(password, forKey: "password")
                        UserDefaults.standard.set(name, forKey: "username")
                        UserDefaults.standard.set(true, forKey: "autologin")
                        UserDefaults.standard.synchronize()
                        
                        self.lastLoginPassword = password
                        self.lastLoginUserName = name
                        DDClientState.sharedInstance.userState = DDUserState.DDUserOnline
                        self.relogining = true
                        if let dic = response as? Dictionary<String, Any> {
                            let user = dic["user"] as? MTTUserEntity
                            RuntimeStatus.sharedInstance.user = user!
                            
                            MTTDatabaseUtil.sharedInstance.openCurrentUserDB()
                            
                            // 加载所有人信息，创建索引拼音
                            self.p_loadAllUsersCompletion(completion: {
                                // Do Nothing
                                DDLog("创建拼音索引以后再做!")
                            })
                            
                            SessionModule.sharedInstance.loadLocalSession(closure: { (isok: Bool) in
                                // 什么都不做
                            })
                            
                            success(user!)
                            
                            MTTNotification.postNotification(notification: DDNotificationUserLoginSuccess, userInfo: nil, object: user)
                        }
                    },failure: { (object: NSError?) in
                        DDLog("MsgServer Check Failed!")
                    })
                    
                }, failure: { (error: Error?) in
                    DDLog("连接TCP服务器失败")
                })
            }
            
        }) { (error: String) in
            print("连接消息服务器失败")
        }
    }
    
    func relogin(success: ()->Void, failure: (String)->Void) {
        DDLog("重新连接中...")
        if DDClientState.sharedInstance.userState == .DDUserOffLine && self.lastLoginPassword != "" && self.lastLoginUserName != "" {
            self.login(name: self.lastLoginUserName, password: self.lastLoginPassword, success: { (user: MTTUserEntity) in
                DDLog("重新登陆成功!")
                NotificationCenter.default.post(name: Notification.Name("ReloginSuccess"), object: nil)
            }, failure: { (error: Error) in
                failure("重新登录失败!")
            })
        }
    }
    
    /**
     *  登录成功后获取所有用户
     *
     *  @param completion 异步执行的closure
     */
    private func p_loadAllUsersCompletion(completion: @escaping ()->Void) {
        let defaults = UserDefaults.standard
        var version: UInt32 = UInt32(defaults.integer(forKey: "alllastupdatetime"))
        MTTDatabaseUtil.sharedInstance.getAllUsers { (contacts: Array<Any>, error: NSError?) in
            if contacts.count != 0 {
                for (_, value) in contacts.enumerated() {
                    DDUserModule.sharedInstance.addMaintanceUser(user: value as? MTTUserEntity)
                    completion()
                }
            } else {
                version = 0
                let api = DDTestAPI()
                api.requestWithObject(object: [version], completion: { (response: Any?, error: Error?) in
                    if error == nil {
                        if let dic = response as? [String: Any] {
                            let responseVersion = dic["alllastupdatetime"] as! UInt32
                            if responseVersion == version && responseVersion != 0 {
                                return
                            }
                            defaults.set(responseVersion, forKey: "alllastupdatetime")
                            let array = dic["userlist"] as! [Any]
                            MTTDatabaseUtil.sharedInstance.insertAllUSers(users: array, completion: { (error: NSError?) in
                                // 什么都不做
                            })
                            DispatchQueue.global().async {
                                for (_, value) in array.enumerated() {
                                    DDUserModule.sharedInstance.addMaintanceUser(user: value as? MTTUserEntity)
                                    DispatchQueue.main.async {
                                        completion()
                                    }
                                }
                            }
                        }
                    }
                })
            }
        }
        
        let api = DDTestAPI()
        api.requestWithObject(object: [version], completion: { (response: Any?, error: Error?) in
            if error == nil {
                if let dic = response as? [String: Any] {
                    let responseVersion = dic["alllastupdatetime"] as! UInt32
                    if responseVersion == version && responseVersion != 0 {
                        return
                    }
                    defaults.set(responseVersion, forKey: "alllastupdatetime")
                    let array = dic["userlist"] as! [Any]
                    MTTDatabaseUtil.sharedInstance.insertAllUSers(users: array, completion: { (error: NSError?) in
                        // 什么都不做
                    })
                    DispatchQueue.global().async {
                        for (_, value) in array.enumerated() {
                            DDUserModule.sharedInstance.addMaintanceUser(user: value as? MTTUserEntity)
                        }
                    }
                }
            }
        })
    }
    
    static let sharedInstance = LoginModule()
    var lastLoginUser: String = ""
    var lastLoginPassword: String = ""
    var lastLoginUserName: String = ""
    var dao: String = ""
    var priorIP: String = ""
    var port: Int = 0
    var relogining: Bool = false
}
