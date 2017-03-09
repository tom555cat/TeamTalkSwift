//
//  SendPushTokenAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/16.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class SendPushTokenAPI: DDSuperAPI, DDAPIScheduleProtocol {
    func requestTimeOutTimeInterval() -> Int {
        return Int(TimeOutTimeInterval)
    }
    
    func requestServiceID() -> UInt16 {
        return SID.SID_LOGIN.rawValue
    }
    
    func responseServiceID() -> UInt16 {
        return SID.SID_LOGIN.rawValue
    }
    
    func requestCommendID() -> UInt16 {
        return SID_LOGIN.IM_DEVICE_TOKEN_REQ.rawValue
    }
    
    func responseCommendID() -> UInt16 {
        return SID_LOGIN.IM_DEVICE_TOKEN_RES.rawValue
    }
    
    func analysisReturenData() -> Analysis? {
        let analysis = { (data: NSData) -> Any? in
            return nil
        }
        return analysis
    }
    
    func packageRequestObject() -> Package? {
        let package = { (object: Any, seqNo: UInt16) -> NSMutableData? in
            if let token = object as? String {
                do {
                    var deviceToken = IM_Login_IMDeviceTokenReq()
                    deviceToken.userId = MTTUserEntity.localIDTopb(userid: (RuntimeStatus.sharedInstance.user?.objID)!)
                    deviceToken.deviceToken = token
                    let dataout = DDDataOutputStream()
                    dataout.writeInt(v: 0)
                    dataout.writeTcpProtocolHeader(sId: SID.SID_LOGIN.rawValue, cId: SID_LOGIN.IM_DEVICE_TOKEN_REQ.rawValue, seqNo: seqNo)
                    dataout.writeDataCount()
                    try dataout.directWriteBytes(v: deviceToken.serializeProtobuf() as NSData)
                    dataout.writeDataCount()
                    return dataout.toByteArray()
                } catch {
                    DDLog("token打包出错!")
                    return nil
                }
            } else {
                return nil
            }
        }
        
        return package
    }
}
