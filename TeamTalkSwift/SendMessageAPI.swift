//
//  SendMessageAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/3/17.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class SendMessageAPI: DDSuperAPI, DDAPIScheduleProtocol {
    
    func requestTimeOutTimeInterval() -> Int {
        return 5
    }
    
    func requestServiceID() -> UInt16 {
        return SID.SID_MSG.rawValue
    }
    
    func responseServiceID() -> UInt16 {
        return SID.SID_MSG.rawValue
    }
    
    func requestCommendID() -> UInt16 {
        return SID_MSG.IM_MSG_DATA.rawValue
    }
    
    func responseCommendID() -> UInt16 {
        return SID_MSG.IM_MSG_DATA_ACK.rawValue
    }
    
    func analysisReturenData() -> Analysis? {
        let analysis = { (data: NSData) -> Any? in
            do {
                let msgDataAck = try IM_Message_IMMsgDataAck.init(protobuf: data as Data)
                return [msgDataAck.msgId, msgDataAck.sessionId]
            } catch {
                DDLog("解析出错!")
                return nil
            }
        }
        
        return analysis
    }
    
    func packageRequestObject() -> Package? {
        let package = { (object: Any, seqNo: UInt16) -> NSMutableData? in
            if let array = object as? [Any] {
                do {
                    _ = array[0] as! String
                    let toId = array[1] as! String
                    let content = array[2] as! Data
                    let type = array[3] as! IM_BaseDefine_MsgType
                    var msgData = IM_Message_IMMsgData()
                    msgData.fromUserId = 0
                    msgData.toSessionId = MTTUtil.changeIDToOriginal(sessionID: toId)
                    msgData.msgData = content
                    msgData.msgType = type
                    msgData.msgId = 0
                    msgData.createTime = 0
                    let dataout = DDDataOutputStream()
                    dataout.writeInt(v: 0)
                    dataout.writeTcpProtocolHeader(sId: SID.SID_MSG.rawValue, cId: SID_MSG.IM_MSG_DATA.rawValue, seqNo: seqNo)
                    try dataout.directWriteBytes(v: msgData.serializeProtobuf() as NSData)
                    dataout.writeDataCount()
                    
                    return dataout.toByteArray()
                } catch {
                    DDLog("打包数据出错!")
                    return nil
                }
            } else {
                return nil
            }
        }
        
        return package
    }
}
