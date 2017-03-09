//
//  ReceiveKickoffAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/22.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class ReceiveKickoffAPI: DDUnrequestSuperAPI, DDAPIUnrequestScheduleProtocol {
    
    func responseServiceID() -> UInt16 {
        return SID.SID_LOGIN.rawValue
    }
    
    func responseCommandID() -> UInt16 {
        return SID_LOGIN.IM_KICK_USER.rawValue
    }
    
    func unrequestAnalysis() -> UnrequestAPIAnalysis {
        let analysis = {(data: NSData) -> Any? in
            do {
              let res = try IM_Login_IMKickUser.init(protobuf: data as Data)
                return res.kickReason
            } catch  {
                DDLog("用户被踢出解析错误!")
                return nil
            }
        }
        return analysis
    }
}
