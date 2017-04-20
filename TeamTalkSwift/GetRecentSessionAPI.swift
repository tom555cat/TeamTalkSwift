//
//  GetRecentSessionAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/17.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class GetRecentSessionAPI: DDSuperAPI, DDAPIScheduleProtocol {
    
    func requestTimeOutTimeInterval() -> Int {
        return 5
    }
    
    func requestServiceID() -> UInt16 {
        return SID.SID_BUDDY_LIST.rawValue
    }
    
    func responseServiceID() -> UInt16 {
        return SID.SID_BUDDY_LIST.rawValue
    }
    
    func requestCommendID() -> UInt16 {
        return SID_BUDDY_LIST.IM_RECENT_CCONTACT_SESSION_REQ.rawValue
    }
    
    func responseCommendID() -> UInt16 {
        return SID_BUDDY_LIST.IM_RECENT_CCONTACT_SESSION_RES.rawValue
    }
    
    func analysisReturenData() -> Analysis? {
        let analysis = { (data: NSData) -> Any? in
            
            do {
               let rsp = try IM_Buddy_IMRecentContactSessionRsp.init(protobuf: data as Data)
                var array = [MTTSessionEntity]()
                
                for (_, sessionInfo) in rsp.contactSessionList.enumerated() {
                    var sessionId = ""
                    let sessionType = sessionInfo.sessionType
                    if sessionType == .single {
                        sessionId = MTTUserEntity.pbUserIdToLocalID(userID: sessionInfo.sessionId)
                    } else {
                        sessionId = MTTGroupEntity.pbGroupIdToLocalID(groupID: sessionInfo.sessionId)
                    }
                    let update_time = sessionInfo.updatedTime
                    let session = MTTSessionEntity.init(sessionID: sessionId, type: sessionType)
                    let lastMsg = String.init(data: sessionInfo.latestMsgData, encoding: String.Encoding.utf8)
                    
                    // 这里没有加密解密
                    
                    session.lastMsg = lastMsg
                    session.lastMsgID = sessionInfo.latestMsgId
                    session.timeInterval = TimeInterval(update_time)
                    array.append(session)
                }
                return array
            } catch {
                return nil
            }
        }
        return analysis
    }
    
    func packageRequestObject() -> Package? {
        let package = { (object: Any, seqNo: UInt16) -> NSMutableData? in
            if let dic = object as? [Any] {
                do {
                    var req = IM_Buddy_IMRecentContactSessionReq()
                    req.userId = 0
                    req.latestUpdateTime = dic[0] as! UInt32
                    let dataout = DDDataOutputStream()
                    dataout.writeInt(v: 0)
                    dataout.writeTcpProtocolHeader(sId: SID.SID_BUDDY_LIST.rawValue, cId: SID_BUDDY_LIST.IM_RECENT_CCONTACT_SESSION_REQ.rawValue, seqNo: seqNo)
                    try dataout.directWriteBytes(v: req.serializeProtobuf() as NSData)
                    dataout.writeDataCount()
                    return dataout.toByteArray()
                } catch {
                    DDLog("打包数据出错")
                    return nil
                }
            } else {
                return nil
            }
        }
        
        return package
    }
}
