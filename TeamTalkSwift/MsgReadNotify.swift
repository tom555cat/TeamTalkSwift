//
//  MsgReadNotify.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/10.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class MsgReadNotify: DDUnrequestSuperAPI, DDAPIUnrequestScheduleProtocol {
    
    func responseServiceID() -> UInt16 {
        return SID.SID_MSG.rawValue
    }
    
    func responseCommandID() -> UInt16 {
        return SID_MSG.IM_MSG_DATA_READ_NOTIFY.rawValue
    }
    
    func unrequestAnalysis() -> UnrequestAPIAnalysis {
        return { (data: NSData) -> Any? in
            do {
                let notify = try IM_Message_IMMsgDataReadNotify.init(protobuf: data as Data)
                let sessionType = notify.sessionType
                let from_id = MTTUtil.changeOriginalToLocalID(originalID: notify.sessionId, sessionType: sessionType)
                let msgId = notify.msgId
                var dic = [String: Any]()
                dic["from_id"] = from_id
                dic["msgId"] = msgId
                dic["type"] = sessionType
                return dic
            } catch {
                DDLog("接收到消息解析错误!")
                return nil
            }
        }
    }
}
