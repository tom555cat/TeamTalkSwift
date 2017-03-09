//
//  DDUnrequestSuperAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/3.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

typealias ReceiveData = (Any, NSError?) -> Void

class DDUnrequestSuperAPI {
    
    var receivedData: ReceiveData? = nil
    
    func registerAPIInAPIScheduleReceiveData(received: @escaping ReceiveData) -> Bool {
        let protocolSelf = self as? DDAPIUnrequestScheduleProtocol
        let registerSuccess = DDAPISchedule.sharedInstance.registerUnrequestAPI(api: protocolSelf!)
        
        if registerSuccess {
            self.receivedData = received
            return true
        } else {
            return false
        }
    }
}
