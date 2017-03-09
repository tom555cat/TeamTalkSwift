//
//  DDSuperAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2016/12/29.
//  Copyright © 2016年 Hello World Corporation. All rights reserved.
//


import Foundation

typealias RequestCompletion = (Any?, NSError?) -> Void

class DDSuperAPI
{
    let TimeOutTimeInterval: Int = 5
    
    static var theSeqNo: UInt16 = 0
    
    var completion: RequestCompletion? = nil
    
    var seqNo: UInt16 = 0
    
    func requestWithObject(object: Any?, completion: @escaping RequestCompletion)
    {
        DDSuperAPI.theSeqNo += 1
        seqNo = DDSuperAPI.theSeqNo
        let protocolSelf = self as? DDAPIScheduleProtocol
        
        // 注册接口
        let registerAPI:Bool = DDAPISchedule.sharedInstance.registerApi(api: protocolSelf!)
        if !registerAPI{
            return
        }
        
        // 注册请求超时
        if (protocolSelf?.requestTimeOutTimeInterval())! > 0 {
            DDAPISchedule.sharedInstance.registerTimeoutApi(api: protocolSelf!)
        }
        
        //
        self.completion = completion
        
        // 数据打包
        let package = protocolSelf?.packageRequestObject()
        let requestData = package!(object, seqNo)
        
        // 发送
        if self is GetMessageQueueAPI {
            DDLog("获取会话消息包发送")
        } else if self is HeartbeatAPI {
            DDLog("发送心跳包!")
        }
        DDAPISchedule.sharedInstance.sendData(data: requestData!)
        
    }
}
