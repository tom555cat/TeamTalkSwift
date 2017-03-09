//
//  DDAPIScheduleProtocol.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2016/12/30.
//  Copyright © 2016年 Hello World Corporation. All rights reserved.
//

import Foundation

typealias Analysis = (NSData) -> Any?

typealias Package = (Any?, UInt16) -> NSMutableData?

protocol DDAPIScheduleProtocol {
    
    // 请求超时时间
    func requestTimeOutTimeInterval() -> Int
    
    // 请求的serviceID
    func requestServiceID() -> UInt16
    
    // 请求返回的serviceID
    func responseServiceID() -> UInt16
    
    // 请求的commendID
    func requestCommendID() -> UInt16
    
    // 请求返回的commendID
    func responseCommendID() -> UInt16
    
    // 解析数据的closure
    func analysisReturenData() -> Analysis?
    
    // 打包数据的closure
    func packageRequestObject() -> Package?
}
