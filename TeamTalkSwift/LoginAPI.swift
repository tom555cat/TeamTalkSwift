//
//  LoginAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/10.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class LoginAPI: DDSuperAPI, DDAPIScheduleProtocol {
    
    //MARK: DDAPIScheduleProtocol
    func requestTimeOutTimeInterval() -> Int {
        return 5
    }
    
    func requestServiceID() -> UInt16 {
        return SID.SID_LOGIN.rawValue
    }
    
    func responseServiceID() -> UInt16 {
        return SID.SID_LOGIN.rawValue
    }
    
    func requestCommendID() -> UInt16 {
        return SID_LOGIN.IM_LOGIN_REQ.rawValue
    }
    
    func responseCommendID() -> UInt16 {
        return SID_LOGIN.IM_LOGIN_RES.rawValue
    }
    
    /**
     *   解析数据的block
     **/
    func analysisReturenData() -> Analysis? {
        return { (data: NSData) -> [String: Any]? in
            //var res: IM_Login_IMLoginRes = IM_Login_IMLoginRes(protobuf: data as Data)
            
            do {
                var res: IM_Login_IMLoginRes = try IM_Login_IMLoginRes.init(protobuf: data as Data)
                let serverTime = res.serverTime
                let loginResult = res.resultCode
                let resultString = res.resultString
                var result = [String: Any]()
                if loginResult != IM_BaseDefine_ResultType.refuseReasonNone {
                    return result
                } else {
                    let user: MTTUserEntity = MTTUserEntity.init(pbUser: res.userInfo)
                    result["serverTime"] = serverTime
                    result["result"] = resultString
                    result["user"] = user
                    return result
                }
            } catch {
                print("analysis Login Response occured error!")
                return nil
            }
        }
    }
    
    /**
     *  打包数据的block
     */
    func packageRequestObject() -> Package? {
        return { (object: Any, seqNo: UInt16) -> NSMutableData? in
            let clientVersion = "MAC/\(Bundle.main.infoDictionary?["CFBundleShortVersionString"]!)-\(Bundle.main.infoDictionary?["CFBundleVersion"]!)"
            var strMsg:String = ""
            var userName:String = ""
            if let array = object as? [Any] {
                strMsg = (array[1] as? String)!
                userName = (array[0] as? String)!
            }
            let dataout = DDDataOutputStream()
            dataout.writeInt(v: 0)
            dataout.writeTcpProtocolHeader(sId: SID.SID_LOGIN.rawValue, cId: SID_LOGIN.IM_LOGIN_REQ.rawValue, seqNo: seqNo)
            
            var login = IM_Login_IMLoginReq()
            login.userName = userName
            login.password = strMsg.MD5()
            login.clientType = IM_BaseDefine_ClientType(rawValue: IM_BaseDefine_ClientType.ios.rawValue)!
            login.clientVersion = clientVersion
            login.onlineStatus = IM_BaseDefine_UserStatType(rawValue: IM_BaseDefine_UserStatType.userStatusOnline.rawValue)!
            do {
                let loginData = try login.serializeProtobuf() as NSData
                dataout.directWriteBytes(v: loginData)
                dataout.writeDataCount()
                return dataout.toByteArray()
            } catch {
                return nil
            }
        }
    }
    
}
