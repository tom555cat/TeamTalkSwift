//
//  DDHttpServer.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/3.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class DDHttpServer
{
    /**
     *  登陆Http服务器
     *
     *  @param success 登陆成功回调的closure
     *  @param failure 登陆失败回调的closure
     *
     *
     **/
    func login(userName: String,
               password: String,
               sucess:(Any) -> Void,
               failure:(Any) -> Void) -> Void {
        //<#function body#>
    }
    
    // 获取MsgServer的IP
    func getMsgIP(block: @escaping (NSDictionary) -> Void, failure: (String) -> Void)
    {
        NetworkTool.sharedInstance.request(requestType: .Get, url: SERVER_ADDR, parameters: [:], succeed: {(response) in
            let dic = NSDictionary.init(dictionary: response!)
            block(dic)
        })
        { (error) in
            guard let error = error else {
                return
            }
            print(error)
        }
    }
}
