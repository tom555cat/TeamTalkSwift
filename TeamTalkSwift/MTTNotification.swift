//
//  MTTNotification.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/5.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class MTTNotification {
    
    class func postNotification(notification: Notification.Name,
                                userInfo: Dictionary<String, Any>?,
                                object: Any?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: notification, object: object, userInfo: userInfo)
        }
    }
    
}
