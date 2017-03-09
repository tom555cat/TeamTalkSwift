//
//  DDAPIUnrequestScheduleProtocol.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/3.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

typealias UnrequestAPIAnalysis = (NSData) -> Any?

protocol DDAPIUnrequestScheduleProtocol {
    
    // 返回数据包中的serviceID
    func responseServiceID() -> UInt16
    
    // 返回数据包中的commandID
    func responseCommandID() -> UInt16
    
    // 解析返回数据包的closure
    func unrequestAnalysis() -> UnrequestAPIAnalysis
}
