//
//  DDMsgServer.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/10.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

let timeOutTimeInterval: Double = 10.0

typealias CheckSuccess = (Any) -> Void

typealias CheckFailure = (Error) -> Void

class DDMsgServer {
    
    init() {
        self.connecting = false
        self.connectTimes = 0
    }
    
    func checkUser(userID: String,
                   password: String,
                   token: String,
                   success: @escaping ([String: Any]?) -> Void,
                   failure: @escaping (NSError) -> Void) {
        if !self.connecting {
            let clientType: Int = 17
            let clientVersion: String = "MAC/\(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!)-\(Bundle.main.infoDictionary!["CFBundleVersion"]!)"
            let parameter: [Any] = [userID, password, clientVersion, clientType]
            let api = LoginAPI()
            api.requestWithObject(object: parameter, completion: { (response: Any?, error: Error?) in
                if error == nil {
                    if let dic = response as? [String: Any] {
                        if let code = dic["code"] as? Int {
                            var errString:String = ""
                            switch code {
                            case 0: errString = "登陆异常"
                            case 1: errString = "连接服务器失败"
                            case 2: errString = "连接服务器失败"
                            case 3: errString = "连接服务器失败"
                            case 4: errString = "连接服务器失败"
                            case 5: errString = "连接服务器失败"
                            case 6: errString = "用户名或密码错误"
                            case 7: errString = "版本过低"
                            default: break
                            }
                            let error1 = NSError(domain: errString, code: code, userInfo: nil)
                            failure(error1)
                            
                        } else {
                            let resultString = dic["resultString"]
                            if resultString == nil {
                                success(dic)
                            }
                        }
                    }
                    
                } else {
                    DDLog("error!!!")
                    failure(error! as NSError)
                }
            } )
        }
    }
    
    private var success: CheckSuccess?
    
    private var failure: CheckFailure?
    
    private var connecting: Bool
    
    private var connectTimes: UInt
}
