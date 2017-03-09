//
//  DDTestAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/9.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class DDTestAPI: DDSuperAPI, DDAPIScheduleProtocol {
    
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
        return SID_BUDDY_LIST.IM_ALL_USER_REQ.rawValue
    }
    
    func responseCommendID() -> UInt16 {
        return SID_BUDDY_LIST.IM_ALL_USER_RES.rawValue
    }
    
    func analysisReturenData() -> Analysis? {
        return { (data: NSData) -> [String: Any]? in
            do {
                let allUserRsp = try IM_Buddy_IMAllUserRsp.init(protobuf: data as Data)
                let alllastupdatetime = allUserRsp.latestUpdateTime
                var userAndVersion = [String: Any]()
                userAndVersion["alllastupdatetime"] = alllastupdatetime
                var userList = [MTTUserEntity]()
                for userInfo in allUserRsp.userList {
                    let user = MTTUserEntity.init(pbUser: userInfo)
                    userList.append(user)
                }
                userAndVersion["userlist"] = userList
                return userAndVersion
            } catch {
                DDLog("获取用户列表请求解析失败")
                DDLog(error.localizedDescription)
                return nil
            }
        }
    }
    
    func packageRequestObject() -> Package? {
        return { (object: Any, seqNo: UInt16) -> NSMutableData? in
            var reqBuilder = IM_Buddy_IMAllUserReq()
            if let array = object as? [Any] {
                reqBuilder.userId = 0
                reqBuilder.latestUpdateTime = array[0] as! UInt32
                let dataout = DDDataOutputStream()
                dataout.writeInt(v: 0)
                dataout.writeTcpProtocolHeader(sId: SID.SID_BUDDY_LIST.rawValue, cId: SID_BUDDY_LIST.IM_ALL_USER_REQ.rawValue, seqNo: seqNo)
                do {
                    try dataout.directWriteBytes(v: reqBuilder.serializeProtobuf() as NSData)
                    dataout.writeDataCount()
                    return dataout.toByteArray()
                } catch  {
                    DDLog("打包请求用户列表失败")
                    return nil
                }
            } else {
                return nil
            }
        }
    }
}
