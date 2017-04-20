//
//  MsgReadACKAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/10.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class MsgReadACKAPI: DDSuperAPI, DDAPIScheduleProtocol {
    func requestTimeOutTimeInterval() -> Int {
        return 0
    }
    
    func requestServiceID() -> UInt16 {
        return SID.SID_MSG.rawValue
    }
    
    func responseServiceID() -> UInt16 {
        return 0
    }
    
    func requestCommendID() -> UInt16 {
        return SID_MSG.IM_MSG_DATA_READ_ACK.rawValue
    }
    
    func responseCommendID() -> UInt16 {
        return 0
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
            if let array = object as? [Any] {
                var readAck = IM_Message_IMMsgDataReadAck()
                readAck.userId = 0
                readAck.sessionId = MTTUtil.changeIDToOriginal(sessionID: array[0] as! String)
                readAck.msgId = array[1] as! UInt32
                readAck.sessionType = IM_BaseDefine_SessionType.init(rawValue: array[2] as! Int)!
                let dataout = DDDataOutputStream()
                dataout.writeInt(v: 0)
                dataout.writeTcpProtocolHeader(sId: SID.SID_MSG.rawValue, cId: SID_MSG.IM_MSG_DATA_READ_ACK.rawValue, seqNo: seqNo)
                do {
                    try dataout.directWriteBytes(v: readAck.serializeProtobuf() as NSData)
                    dataout.writeDataCount()
                    return dataout.toByteArray()
                } catch {
                    DDLog("打包数据出错!")
                }
            }
            return nil
        }
        return package
    }
}
