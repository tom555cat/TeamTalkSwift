//
//  MTTUsersStatAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/20.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class MTTUsersStatAPI: DDSuperAPI, DDAPIScheduleProtocol {
    
    func requestTimeOutTimeInterval() -> Int {
        return Int(TimeOutTimeInterval)
    }
    
    func requestServiceID() -> UInt16 {
        return SID.SID_BUDDY_LIST.rawValue
    }
    
    func responseServiceID() -> UInt16 {
        return SID.SID_BUDDY_LIST.rawValue
    }
    
    func requestCommendID() -> UInt16 {
        return SID_BUDDY_LIST.IM_USERS_STAT_REQ.rawValue
    }
    
    func responseCommendID() -> UInt16 {
        return SID_BUDDY_LIST.IM_USERS_STAT_RSP.rawValue
    }
    
    func analysisReturenData() -> Analysis? {
        let analysis = { (data: NSData) -> Any? in
            do {
                let allUsersStatRsp = try IM_Buddy_IMUsersStatRsp.init(protobuf: data as Data)
                var array = [Any]()
                var userList = [Any]()
                for userStat in allUsersStatRsp.userStatList {
                    userList.append(userStat.userId)
                    userList.append(userStat.status)
                }
                array.append(userList)
                return array
            } catch {
                DDLog("解析出错!")
                return nil
            }
        }
        return analysis
    }
    
    func packageRequestObject() -> Package? {
        let package = { (object: Any, seqNo: UInt16) -> NSMutableData? in
            if let array = object as? [Any] {
                do {
                    var queryPush = IM_Buddy_IMUsersInfoReq()
                    queryPush.userId = 0
                    queryPush.userIdList = array as! [UInt32]
                    
                    let dataout = DDDataOutputStream()
                    dataout.writeInt(v: 0)
                    dataout.writeTcpProtocolHeader(sId: SID.SID_BUDDY_LIST.rawValue, cId: SID_BUDDY_LIST.IM_USERS_STAT_REQ.rawValue, seqNo: seqNo)
                    
                    try dataout.directWriteBytes(v: queryPush.serializeProtobuf() as NSData)
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
