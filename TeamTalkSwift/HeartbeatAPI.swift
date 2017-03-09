//
//  HeartbeatAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/13.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class HeartbeatAPI: DDSuperAPI, DDAPIScheduleProtocol {
    func requestTimeOutTimeInterval() -> Int {
        return 0
    }
    
    func requestServiceID() -> UInt16 {
        return SID.SID_OTHER.rawValue
    }
    
    func responseServiceID() -> UInt16 {
        return SID.SID_OTHER.rawValue
    }
    
    func requestCommendID() -> UInt16 {
        return SID_OTHER.IM_HEART_BEAT.rawValue
    }
    
    func responseCommendID() -> UInt16 {
        return SID_OTHER.IM_HEART_BEAT.rawValue
    }
    
    func analysisReturenData() -> Analysis? {
        let analysis = { (data: NSData) -> [String: Any]? in
            // 什么都不做
            return nil
        }
        return analysis
    }
    
    func packageRequestObject() -> Package? {
        let package = { (object: Any, seqNo: UInt16) -> NSMutableData? in
            do {
                let builder = IM_Other_IMHeartBeat()
                let dataout = DDDataOutputStream()
                dataout.writeInt(v: 0)
                dataout.writeTcpProtocolHeader(sId: SID.SID_OTHER.rawValue, cId: SID_OTHER.IM_HEART_BEAT.rawValue, seqNo: seqNo)
                try dataout.directWriteBytes(v: builder.serializeProtobuf() as NSData)
                dataout.writeDataCount()
                return dataout.toByteArray()
            } catch {
                DDLog("打包心跳数据包失败！")
                return nil
            }
        }
        return package
    }
}
