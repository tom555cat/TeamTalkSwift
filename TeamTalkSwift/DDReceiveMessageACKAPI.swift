//
//  DDReceiveMessageACKAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/14.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class DDReceiveMessageACKAPI: DDSuperAPI, DDAPIScheduleProtocol {
    
    func requestTimeOutTimeInterval() -> Int {
        return 0
    }
    
    func requestServiceID() -> UInt16 {
        return SID.SID_MSG.rawValue
    }
    
    func responseServiceID() -> UInt16 {
        return SID.SID_MSG.rawValue
    }
    
    func requestCommendID() -> UInt16 {
        return SID_MSG.IM_MSG_DATA_ACK.rawValue
    }
    
    func responseCommendID() -> UInt16 {
        return SID_MSG.IM_MSG_DATA_ACK.rawValue
    }
    
    func analysisReturenData() -> Analysis? {
        let analysis = {(data: NSData) -> [String: Any]? in
            return nil
        }
        
        return analysis
    }
    
    func packageRequestObject() -> Package? {
        let package = { (object: Any, seqNo: UInt16) -> NSMutableData? in
            if let array = object as? [Any] {
                let dataout = DDDataOutputStream()
                var dataAck = IM_Message_IMMsgDataAck()
                dataAck.userId = 0
                dataAck.msgId = array[1] as! UInt32
                dataAck.sessionId = MTTUtil.changeIDToOriginal(sessionID: array[2] as! String)
                dataAck.sessionType = IM_BaseDefine_SessionType.init(rawValue: array[3] as! Int)!
                dataout.writeInt(v: 0)
                dataout.writeTcpProtocolHeader(sId: SID.SID_MSG.rawValue, cId: SID_MSG.IM_MSG_DATA_ACK.rawValue, seqNo: seqNo)
                do {
                    try dataout.directWriteBytes(v: dataAck.serializeProtobuf() as NSData)
                    dataout.writeDataCount()
                    return dataout.toByteArray()
                } catch {
                    DDLog("打包收到信息确认出错")
                    return nil
                }
            }
            return nil
        }
        
        return package
    }
    
}
