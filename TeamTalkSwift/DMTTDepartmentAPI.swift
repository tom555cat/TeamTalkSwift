//
//  DMTTDepartmentAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/4/15.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class DMTTDepartmentAPI: DDSuperAPI, DDAPIScheduleProtocol {
    
    func requestTimeOutTimeInterval() -> Int {
        return 5
    }
    
    func requestServiceID() -> UInt16 {
        return 2
    }
    
    func responseServiceID() -> UInt16 {
        return 2
    }
    
    func requestCommendID() -> UInt16 {
        return 18
    }
    
    func responseCommendID() -> UInt16 {
        return 19
    }
    
    func analysisReturenData() -> Analysis? {
        let analysis = { (data: NSData) -> Any? in
            do {
                let bodyData = DDDataInputStream.dataInputStreamWithData(aData: data as Data)
                let departCount = try bodyData.readInt()
                var array = [[String: Any]]()
                for _ in 0..<departCount {
                    let departID = bodyData.readUTF()!
                    let title = bodyData.readUTF()!
                    let description = bodyData.readUTF()!
                    let parentID = bodyData.readUTF()!
                    let leader = bodyData.readUTF()!
                    let isDelete = try bodyData.readInt()
                    let result = ["departCount": departCount, "departID": departID, "title": title, "description": description, "parentID": parentID, "leader": leader, "isDelete": isDelete] as [String : Any]
                    array.append(result)
                }
                
                return array
                
            } catch {
                DDLog("从数据读取出错！")
                return nil
            }
            
        }
        
        return analysis
    }
    
    func packageRequestObject() -> Package? {
        let package = { (object: Any, seqNo: UInt16) -> NSMutableData? in
            let dataout = DDDataOutputStream()
            dataout.writeInt(v: IM_PDU_HEADER_LEN)
            dataout.writeTcpProtocolHeader(sId: 2, cId: 18, seqNo: seqNo)
            return dataout.toByteArray()
        }
        
        return package
    }
}
