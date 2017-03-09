//
//  GetGroupInfoAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/15.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class GetGroupInfoAPI: DDSuperAPI, DDAPIScheduleProtocol {
    
    func requestTimeOutTimeInterval() -> Int {
        return 0
    }
    
    func requestServiceID() -> UInt16 {
        return SID.SID_GROUP.rawValue
    }
    
    func responseServiceID() -> UInt16 {
        return SID.SID_GROUP.rawValue
    }
    
    func requestCommendID() -> UInt16 {
        return SID_GROUP.IM_GROUP_INFO_LIST_REQ.rawValue
    }
    
    func responseCommendID() -> UInt16 {
        return SID_GROUP.IM_GROUP_INFO_LIST_RES.rawValue
    }
    
    func analysisReturenData() -> Analysis? {
        let analysis = { (data: NSData) -> Any? in
            do {
                let rsp = try IM_Group_IMGroupInfoListRsp.init(protobuf: data as Data)
                var array = [MTTGroupEntity]()
                for info in rsp.groupInfoList {
                    let group = MTTGroupEntity.initMTTGroupEntityFromPBData(groupInfo: info)
                    array.append(group)
                }
                return array
            } catch {
                DDLog("解析获取群信息出错")
                return nil
            }
        }
        
        return analysis
    }
    
    func packageRequestObject() -> Package? {
        let package = { (object: Any, seqNo: UInt16) -> NSMutableData? in
            if let array = object as? [Any] {
                let dataout = DDDataOutputStream()
                var info = IM_Group_IMGroupInfoListReq()
                var groupInfo = IM_BaseDefine_GroupVersionInfo()
                
                groupInfo.groupId = array[0] as! UInt32
                groupInfo.version = array[1] as! UInt32
                info.userId = 0
                info.groupVersionList = [groupInfo]
                dataout.writeInt(v: 0)
                dataout.writeTcpProtocolHeader(sId: SID.SID_GROUP.rawValue, cId: SID_GROUP.IM_GROUP_INFO_LIST_REQ.rawValue, seqNo: seqNo)
                do {
                    try dataout.directWriteBytes(v: info.serializeProtobuf() as NSData)
                    dataout.writeDataCount()
                    return dataout.toByteArray()
                } catch {
                    DDLog("发送请求群信息打包出错")
                    return nil
                }
            }
            return nil
        }
        
        return package
    }
}
