//
//  GetMessageQueueAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/15.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class GetMessageQueueAPI: DDSuperAPI, DDAPIScheduleProtocol {
    
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
        return SID_MSG.IM_GET_MSG_LIST_REQ.rawValue
    }
    
    func responseCommendID() -> UInt16 {
        return SID_MSG.IM_GET_MSG_LIST_RSP.rawValue
    }
    
    func analysisReturenData() -> Analysis? {
        let analysis = { (data: NSData) -> Any? in
            do {
                let rsp = try IM_Message_IMGetMsgListRsp.init(protobuf: data as Data)
                let sessionType = rsp.sessionType
                let sessionID = MTTUtil.changeOriginalToLocalID(originalID: rsp.sessionId, sessionType: sessionType)
                _ = rsp.msgIdBegin
                var msgArray = [MTTMessageEntity]()
                for msgInfo in rsp.msgList {
                    let msg = try MTTMessageEntity.makeMessageFromPB(info: msgInfo, sessionType: sessionType)
                    msg.sessionId = sessionID
                    msg.state = .DDMessageSendSuccess
                    msgArray.append(msg)
                }
                return msgArray
            } catch {
                DDLog("解析接收信息数据包出错！")
                return nil
            }
        }
        
        return analysis
    }
    
    func packageRequestObject() -> Package? {
        let package = { (object: Any, seqNo: UInt16) -> NSMutableData? in
            if let array = object as? [Any] {
                var getMsgListReq = IM_Message_IMGetMsgListReq()
                getMsgListReq.msgIdBegin = array[0] as! UInt32
                getMsgListReq.userId = 0
                getMsgListReq.msgCnt = array[1] as! UInt32
                getMsgListReq.sessionType = IM_BaseDefine_SessionType(rawValue: array[2] as! Int)!
                getMsgListReq.sessionId = MTTUtil.changeIDToOriginal(sessionID: array[3] as! String)
                
                let dataout = DDDataOutputStream()
                dataout.writeInt(v: 0)
                dataout.writeTcpProtocolHeader(sId: SID.SID_MSG.rawValue, cId: SID_MSG.IM_GET_MSG_LIST_REQ.rawValue, seqNo: seqNo)
                do {
                    try dataout.directWriteBytes(v: getMsgListReq.serializeProtobuf() as NSData)
                    dataout.writeDataCount()
                    return dataout.toByteArray()
                } catch {
                    DDLog("打包出错")
                    return nil
                }
            } else {
                return nil
            }
        }
        
        return package
    }
    
}
