//
//  MTTNightModeAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/4/19.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class MTTNightModeAPI: DDSuperAPI, DDAPIScheduleProtocol {
    
    func requestTimeOutTimeInterval() -> Int {
        return 5
    }
    
    func requestServiceID() -> UInt16 {
        return SID.SID_LOGIN.rawValue
    }
    
    func responseServiceID() -> UInt16 {
        return SID.SID_LOGIN.rawValue
    }
    
    func requestCommendID() -> UInt16 {
        return SID_LOGIN.IM_QUERY_PUSH_SHIELD_REQ.rawValue
    }
    
    func responseCommendID() -> UInt16 {
        return SID_LOGIN.IM_QUERY_PUSH_SHIELD_RES.rawValue
    }
    
    func analysisReturenData() -> Analysis? {
        let analysis = { (data: NSData) -> Any? in
            
            do {
                let queryPush = try IM_Login_IMQueryPushShieldRsp.init(protobuf: data as Data)
                return [queryPush.shieldStatus]    // [UInt32]
            } catch {
                DDLog("解析出错!")
                return nil
            }
        }
        
        return analysis
    }
    
    func packageRequestObject() -> Package? {
        let package = { (object: Any, seqNo: UInt16) -> NSMutableData? in
            var queryPush = IM_Login_IMQueryPushShieldReq()
            queryPush.userId = 0
            
            let dataout = DDDataOutputStream()
            dataout.writeInt(v: 0)
            dataout.writeTcpProtocolHeader(sId: SID.SID_LOGIN.rawValue, cId: SID_LOGIN.IM_QUERY_PUSH_SHIELD_REQ.rawValue, seqNo: seqNo)
            
            do {
                try dataout.directWriteBytes(v: queryPush.serializeProtobuf() as NSData)
                dataout.writeDataCount()
                return dataout.toByteArray()
            } catch {
                DDLog("数据打包出错!")
                return nil
            }
        }
        
        return package
    }
}
