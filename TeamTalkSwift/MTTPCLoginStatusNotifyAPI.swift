//
//  MTTPCLoginStatusNotifyAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/22.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class MTTPCLoginStatusNotifyAPI: DDUnrequestSuperAPI, DDAPIUnrequestScheduleProtocol {
    
    func responseServiceID() -> UInt16 {
        return SID.SID_BUDDY_LIST.rawValue
    }
    
    func responseCommandID() -> UInt16 {
        return SID_BUDDY_LIST.IM_PC_LOGIN_STATUS_NOTIFY.rawValue
    }
    
    func unrequestAnalysis() -> UnrequestAPIAnalysis {
        let analysis = {(data: NSData) -> [String: Any]? in
            do {
                let res = try IM_Buddy_IMPCLoginStatusNotify(protobuf: data as Data)
                var dic = [String: Any]()
                dic["uid"] = res.userId
                dic["loginStat"] = res.loginStat
                return dic
            } catch {
                DDLog("用户状态发生变化解析出错!")
                return nil
            }
        }
        
        return analysis
    }
}
