//
//  RemoveSessionAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/22.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class RemoveSessionAPI: DDSuperAPI, DDAPIScheduleProtocol {

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
        return SID_BUDDY_LIST.IM_REMOVE_SESSION_REQ.rawValue
    }
    
    func responseCommendID() -> UInt16 {
        return SID_BUDDY_LIST.IM_REMOVE_SESSION_RES.rawValue
    }
    
    func analysisReturenData() -> Analysis? {
        let analysis = { (data: NSData) -> Any? in
            return nil
        }
        return analysis
    }
    
    func packageRequestObject() -> Package? {
        let package = { (object: Any, seqNo: UInt16) -> NSMutableData? in
            if let array = object as? [Any] {
                
                do {
                    let sessionId = array[0] as! String
                    let sessionType = array[1] as! IM_BaseDefine_SessionType
                    var removeSession = IM_Buddy_IMRemoveSessionReq()
                    removeSession.userId = 0
                    removeSession.sessionId = MTTUtil.changeIDToOriginal(sessionID: sessionId)
                    removeSession.sessionType = sessionType
                    let dataout = DDDataOutputStream()
                    dataout.writeInt(v: 0)
                    dataout.writeTcpProtocolHeader(sId: SID.SID_BUDDY_LIST.rawValue, cId: SID_BUDDY_LIST.IM_REMOVE_SESSION_REQ.rawValue, seqNo: seqNo)
                    try dataout.directWriteBytes(v: removeSession.serializeProtobuf() as NSData)
                    dataout.writeDataCount()
                    return dataout.toByteArray()
                } catch {
                    DDLog("打包出错!")
                    return nil
                }
            }
            return nil
        }
        
        return package
    }
    
}
