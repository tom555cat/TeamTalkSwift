//
//  DDReceiveMessageAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/14.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class DDReceiveMessageAPI: DDUnrequestSuperAPI, DDAPIUnrequestScheduleProtocol {
    
    func responseServiceID() -> UInt16 {
        return SID.SID_MSG.rawValue
    }
    
    func responseCommandID() -> UInt16 {
        return SID_MSG.IM_MSG_DATA.rawValue
    }
    
    func unrequestAnalysis() -> UnrequestAPIAnalysis {
        let analysis = { (data: NSData) -> Any? in
            do {
                let msgData = try IM_Message_IMMsgData.init(protobuf: data as Data)
                let msg = try MTTMessageEntity.makeMessageFromPBData(data: msgData)
                msg.state = .DDMessageSendSuccess
                return msg
            } catch {
                DDLog("解析接收消息出错！")
                return nil
            }
        }
        return analysis
    }
}
