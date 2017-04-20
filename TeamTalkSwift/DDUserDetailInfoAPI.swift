//
//  DDUserDetailInfoAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/4/18.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class DDUserDetailInfoAPI: DDSuperAPI, DDAPIScheduleProtocol {
    
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
        return SID_BUDDY_LIST.IM_USERS_INFO_REQ.rawValue
    }
    
    func responseCommendID() -> UInt16 {
        return SID_BUDDY_LIST.IM_USERS_INFO_RES.rawValue
    }
    
    func analysisReturenData() -> Analysis? {
        let analysis = { (data: NSData) -> Any? in
            do {
                let rsp = try IM_Buddy_IMUsersInfoRsp.init(protobuf: data as Data)
                var userList = [MTTUserEntity]()
                for userInfo in rsp.userInfoList {
                    let user = MTTUserEntity.init(pbUser: userInfo)
                    userList.append(user)
                }
                return userList
            } catch {
                DDLog("解析出错!")
                return nil
            }
        }
        
        return analysis
    }
    
    func packageRequestObject() -> Package? {
        let package = { (object: Any, seqNo: UInt16) -> NSMutableData? in
            if let users = object as? [UInt32] {
                var userInfo = IM_Buddy_IMUsersInfoReq()
                userInfo.userId = 0
                userInfo.userIdList = users
                
                let dataout = DDDataOutputStream()
                dataout.writeInt(v: 0)
                dataout.writeTcpProtocolHeader(sId: SID.SID_BUDDY_LIST.rawValue, cId: SID_BUDDY_LIST.IM_USERS_INFO_REQ.rawValue, seqNo: seqNo)
                
                do {
                    try dataout.directWriteBytes(v: userInfo.serializeProtobuf() as NSData)
                    dataout.writeDataCount()
                    return dataout.toByteArray()
                } catch {
                    DDLog("打包出错!")
                    return nil
                }
            } else {
                return nil
            }
        }
        
        return package
    }
}
