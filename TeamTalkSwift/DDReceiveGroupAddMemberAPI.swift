//
//  DDReceiveGroupAddMemberAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/15.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class DDReceiveGroupAddMemberAPI: DDUnrequestSuperAPI, DDAPIUnrequestScheduleProtocol {
    
    func responseServiceID() -> UInt16 {
        return SID.SID_GROUP.rawValue
    }
    
    // 原来写的是“IM_GROUP_CHANGE_MEMBER_REQ”，感觉应该是_RES
    func responseCommandID() -> UInt16 {
        return SID_GROUP.IM_GROUP_CHANGE_MEMBER_REQ.rawValue
    }
    
    func unrequestAnalysis() -> UnrequestAPIAnalysis {
        let analysis = { (data: NSData) -> Any? in
            do {
                let bodyData = try DDDataInputStream.dataInputStreamWithData(aData: data as Data)
                let result = try bodyData.readInt()
                if result != 0 {
                    return nil
                }
                let groupID = bodyData.readUTF()
                let userCnt = try bodyData.readInt()
                let group = DDGroupModule.sharedInstance.getGroup(byGroupID: groupID!)
                if group != nil {
                    for i in 0..<userCnt {
                        let userID = bodyData.readUTF()
                        if !(group?.groupUserIds?.contains(userID!))! {
                            group?.groupUserIds?.append(userID!)
                            group?.addFixOrderGroupUserIDS(ID: userID!)
                        }
                    }
                }
                
                DDLog("result: \(result), groupID: \(groupID)")
                return group
                
            } catch {
                DDLog("读取数据发生错误!")
                return nil
            }
        }
        
        return analysis
    }
}
