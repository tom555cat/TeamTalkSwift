//
//  MTTSignNotifyAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/22.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class MTTSignNotifyAPI: DDUnrequestSuperAPI, DDAPIUnrequestScheduleProtocol {
    
    func responseServiceID() -> UInt16 {
        return SID.SID_BUDDY_LIST.rawValue
    }
    
    func responseCommandID() -> UInt16 {
        return SID_BUDDY_LIST.IM_SIGN_INFO_CHANGED_NOTIFY.rawValue
    }
    
    func unrequestAnalysis() -> UnrequestAPIAnalysis {
        let analysis = {(data: NSData) -> [String: Any]? in
            do {
                let res = try IM_Buddy_IMSignInfoChangedNotify.init(protobuf: data as Data)
                var dic = [String: Any]()
                dic["uid"] = res.changedUserId
                dic["sign"] = res.signInfo
                return dic
            } catch  {
                DDLog("朋友修改签名解析错误!")
                return nil
            }
        }
        
        return analysis
    }
}
