//
//  GetUnreadMessagesAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/20.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class GetUnreadMessagesAPI: DDSuperAPI, DDAPIScheduleProtocol {
    
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
        return SID_MSG.IM_UNREAD_MSG_CNT_REQ.rawValue
    }
    
    func responseCommendID() -> UInt16 {
        return SID_MSG.IM_UNREAD_MSG_CNT_RSP.rawValue
    }
    
    func analysisReturenData() -> Analysis? {
        let analysis = { (data: NSData) -> Any? in
            do {
                let unreadRsp = try IM_Message_IMUnreadMsgCntRsp.init(protobuf: data as Data)
                var dic = [String: Any]()
                let m_total_cnt = unreadRsp.totalCnt
                dic["m_total_cnt"] = m_total_cnt
                var array = [Any]()
                for (_, unreadInfo) in unreadRsp.unreadinfoList.enumerated() {
                    var userID = ""
                    let sessionType = unreadInfo.sessionType
                    if sessionType == .single {
                        userID = MTTUserEntity.pbUserIdToLocalID(userID: unreadInfo.sessionId)
                    } else {
                        userID = MTTGroupEntity.pbGroupIdToLocalID(groupID: unreadInfo.sessionId)
                    }
                    let unread_cnt = unreadInfo.unreadCnt
                    let latest_msg_id = unreadInfo.latestMsgId
                    let latest_msg_content = String.init(data: unreadInfo.latestMsgData, encoding: String.Encoding.utf8)
                    let session = MTTSessionEntity.init(sessionID: userID, type: sessionType)
                    session.unReadMsgCount = Int(unread_cnt)
                    session.lastMsg = latest_msg_content
                    session.lastMsgID = latest_msg_id
                    array.append(session)
                }
                dic["sessions"] = array
                return dic
            } catch {
                DDLog("解析出错!")
                return nil
            }
        }
        
        return analysis
    }
    
    func packageRequestObject() -> Package? {
        let package = { (object: Any, seqNo: UInt16) -> NSMutableData? in
            do {
                var unreadReq = IM_Message_IMUnreadMsgCntReq()
                unreadReq.userId = 0
                let dataout = DDDataOutputStream()
                dataout.writeInt(v: 0)
                dataout.writeTcpProtocolHeader(sId: SID.SID_MSG.rawValue, cId: SID_MSG.IM_UNREAD_MSG_CNT_REQ.rawValue, seqNo: seqNo)
                try dataout.directWriteBytes(v: unreadReq.serializeProtobuf() as NSData)
                dataout.writeDataCount()
                return dataout.toByteArray()
            } catch {
                DDLog("打包数据出错")
                return nil
            }
        }
        
        return package
    }
}
