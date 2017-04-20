//
//  DDFixedGroupAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/4/15.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class DDFixedGroupAPI: DDSuperAPI, DDAPIScheduleProtocol {
    
    func requestTimeOutTimeInterval() -> Int {
        return 5
    }
    
    func requestServiceID() -> UInt16 {
        return SID.SID_GROUP.rawValue
    }
    
    func responseServiceID() -> UInt16 {
        return SID.SID_GROUP.rawValue
    }
    
    func requestCommendID() -> UInt16 {
        return SID_GROUP.IM_NORMAL_GROUP_LIST_REQ.rawValue
    }
    
    func responseCommendID() -> UInt16 {
        return SID_GROUP.IM_NORMAL_GROUP_LIST_RES.rawValue
    }
    
    func analysisReturenData() -> Analysis? {
        let analysis = { (data: NSData) -> Any? in
            
            do {
                let imNormalRsp = try IM_Group_IMNormalGroupListRsp.init(protobuf: data as Data)
                var array = [[String: UInt32]]()
                for info in imNormalRsp.groupVersionList {
                    let dic = ["groupid": info.groupId, "version": info.version]
                    array.append(dic)
                }
                return array
                
            } catch {
                DDLog("解析出错")
                return nil
            }
        }
        
        return analysis
    }
    
    func packageRequestObject() -> Package? {
        let package = { (object: Any, seqNo: UInt16) -> NSMutableData? in
            let dataout = DDDataOutputStream()
            var imnormal = IM_Group_IMNormalGroupListReq()
            imnormal.userId = 0
            dataout.writeInt(v: 0)
            dataout.writeTcpProtocolHeader(sId: SID.SID_GROUP.rawValue, cId: SID_GROUP.IM_NORMAL_GROUP_LIST_REQ.rawValue, seqNo: seqNo)
            
            do {
                try dataout.directWriteBytes(v: imnormal.serializeProtobuf() as NSData)
                dataout.writeDataCount()
                return dataout.toByteArray()
            } catch {
                DDLog("打包出错!")
                return nil
            }
        }
        
        return package
    }
}
