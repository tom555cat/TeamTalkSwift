//
//  DDAPISchedule.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2016/12/30.
//  Copyright © 2016年 Hello World Corporation. All rights reserved.
//

import Foundation

func MAP_REQUEST_KEY(api: DDAPIScheduleProtocol) -> String
{
    let superApi = api as! DDSuperAPI
    let seqNo = superApi.seqNo
    return String.init(format: "%i-%i-%i", api.requestServiceID(), api.requestCommendID(), seqNo)
}

func MAP_RESPONSE_KEY(api: DDAPIScheduleProtocol) -> String
{
    let superApi = api as! DDSuperAPI
    let seqNo = superApi.seqNo
    return String.init(format: "response_%i-%i-%i", api.responseServiceID(), api.responseCommendID(), seqNo)
}

func MAP_DATA_RESPONSE_KEY(serverData: ServerDataType) -> String
{
    return String.init(format: "response_%i-%i-%i", serverData.serviceID!, serverData.commandID!, serverData.seqNo!)
}

func MAP_UNREQUEST_KEY(api: DDAPIUnrequestScheduleProtocol) -> String
{
    return String.init(format: "%i-%i", api.responseServiceID(), api.responseCommandID())
}

func MAP_DATA_UNREQUEST_KEY(serverData: ServerDataType) -> String
{
    return String.init(format: "%i-%i", serverData.serviceID!, serverData.commandID!)
}

struct ServerDataType {
    var serviceID: UInt16?
    var commandID: UInt16?
    var seqNo: UInt16?
}

func DDMakeServerDataType(serviceID: UInt16, commandID: UInt16, seqNo: UInt16) -> ServerDataType {
    var type = ServerDataType()
    type.serviceID = serviceID
    type.commandID = commandID
    type.seqNo = seqNo
    return type
}

class DDAPISchedule
{
    let apiScheduleQueue = DispatchQueue(label: "com.mogujie.duoduo.apiSchedule")
    //let apiScheduleQueue = DispatchQueue.global()
    
    // 发出请求API字典
    var apiRequestMap: Dictionary<String, DDAPIScheduleProtocol> = [:]
    // 处理响应API字典
    var apiResponseMap: Dictionary<String, DDAPIScheduleProtocol> = [:]
    // 不发送只响应的API字典
    var unrequestMap: Dictionary<String, DDAPIUnrequestScheduleProtocol> = [:]
    
    // MARK: - 单例
    static let sharedInstance = DDAPISchedule()
    
    // 注册接口，此接口只应该在DDSuperAPI中被使用
    func registerApi(api: DDAPIScheduleProtocol) -> Bool
    {
        var registerSuccess = false
        
        apiScheduleQueue.sync(){
            // 如果没有解析closure就注册成功
            if api.analysisReturenData() == nil
            {
                registerSuccess = true
            }
            
            if !apiRequestMap.keys.contains(MAP_REQUEST_KEY(api: api))
            {
                apiRequestMap[MAP_REQUEST_KEY(api: api)] = api
                registerSuccess = true
            } else {
                registerSuccess = false
            }
            
            // 注册返回数据处理API
            if !apiResponseMap.keys.contains(MAP_RESPONSE_KEY(api: api))
            {
                apiResponseMap[MAP_RESPONSE_KEY(api: api)] = api
            }
        }
        return registerSuccess
    }
    
    // 注册超时的查询表，此接口只应该在DDSuper中调用
    func registerTimeoutApi(api: DDAPIScheduleProtocol)
    {
        let delayInSeconds = api.requestTimeOutTimeInterval()
        if delayInSeconds == 0 {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(delayInSeconds) * Double(NSEC_PER_SEC)) {
            MTTSundriesCenter.sharedInstance.pushTaskToSerialQueue {
                if let superApi = api as? DDSuperAPI {
                    let completion = superApi.completion!
                    let error = NSError.init(domain: "请求超时", code: 1001, userInfo: nil)
                    DispatchQueue.main.sync(execute: {
                        completion(nil, error)
                    })
                    self.p_requestCompletion(api: api)
                }
            }
        }
    }
    
    // 接收到服务器端的数据进行解析，对外的接口
    func receiveServerData(data: NSData, dataType: ServerDataType)
    {
        apiScheduleQueue.async {
            let key = MAP_DATA_RESPONSE_KEY(serverData: dataType)
            // 根据key区调用注册api的completion
            let api = self.apiResponseMap[key]
            if api != nil {
                if let superAPI = api as? DDSuperAPI {
                    let completion = superAPI.completion!
                    let analysis = api?.analysisReturenData()
                    let response = analysis!(data)!
                    self.p_requestCompletion(api: api!)
                    
                    DispatchQueue.main.async {
                        // 本来要传入空的error
                        completion(response, nil)
                    }
                }
            } else {
                // 没有请求，只响应的API
                let unrequestKey = MAP_DATA_UNREQUEST_KEY(serverData: dataType)
                let unrequestAPI = self.unrequestMap[unrequestKey]
                let unrequestAnalysis = unrequestAPI?.unrequestAnalysis()
                let object = unrequestAnalysis!(data)
                if let unrequestSuperAPI = unrequestAPI as? DDUnrequestSuperAPI{
                    let received = unrequestSuperAPI.receivedData
                    DispatchQueue.main.async {
                        let error = NSError.init()
                        received!(object, error)
                    }
                }
                
            }
        }
    }
    
    // 注册返回数据处理接口
    func registerUnrequestAPI(api: DDAPIUnrequestScheduleProtocol) -> Bool
    {
        var registerSuccess: Bool = false
        apiScheduleQueue.sync {
            let key = MAP_UNREQUEST_KEY(api: api)
            if unrequestMap.keys.contains(key) {
                registerSuccess = false
            } else {
                unrequestMap[key] = api
                registerSuccess = true
            }
        }
        return registerSuccess
    }
    
    func sendData(data: NSMutableData) -> Void
    {
        apiScheduleQueue.async {
            DDTcpClientManager.sharedInstance.writeToSocket(data: data)
        }
    }
    
    private func p_requestCompletion(api: DDAPIScheduleProtocol)
    {
        apiRequestMap.removeValue(forKey: MAP_REQUEST_KEY(api: api))
        apiResponseMap.removeValue(forKey: MAP_RESPONSE_KEY(api: api))
    }
}
