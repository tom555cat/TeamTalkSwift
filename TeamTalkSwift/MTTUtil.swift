//
//  MTTUtil.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/10.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class MTTUtil {
    /*
    +(void)setMsfsUrl:(NSString*)url
    {
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:@"msfsurl"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    }
    */
    class func setMsfsUrl(url: String) {
        UserDefaults.standard.set(url, forKey: "msfsurl")
        UserDefaults.standard.synchronize()
    }
    
    class func changeOriginalToLocalID(originalID: UInt32, sessionType: IM_BaseDefine_SessionType) -> String {
        if sessionType == IM_BaseDefine_SessionType.single {
            return MTTUserEntity.pbUserIdToLocalID(userID: originalID)
        }
        // 需要创建MTTGroupEntity
        return MTTGroupEntity.pbGroupIdToLocalID(groupID: originalID)
    }
    
    class func getDBVersion() -> Int{
        return UserDefaults.standard.integer(forKey: "dbVersion")
    }
    
    class func getLastDBVersion() -> Int {
        return UserDefaults.standard.integer(forKey: "lastDbVersion")
    }
    
    class func setLastDBVersion(version: Int) {
        UserDefaults.standard.set(version, forKey: "lastDbVersion")
        UserDefaults.standard.synchronize()
    }
    
    class func changeIDToOriginal(sessionID: String) -> UInt32 {
        let array = sessionID.components(separatedBy: "_")
        if array.count > 1 {
            return UInt32.init(array[1])!
        }
        return 0
    }
    
    class func checkFixedTop(sessionID: String) -> Bool {
        if let allUsers = UserDefaults.standard.array(forKey: "fixedTopUsers") as? [String] {
            return allUsers.contains(sessionID)
        } else {
            return false
        }
    }
    
    // MARK: - 气泡功能
    class func getBubbleTypeLeft(left: Bool) -> String? {
        var bubbleType: String?
        if left {
            bubbleType = UserDefaults.standard.string(forKey: "userLeftCustomerBubble")
            if bubbleType == nil {
                bubbleType = "default_white"
            }
        } else {
            bubbleType = UserDefaults.standard.string(forKey: "userRightCustomerBubble")
            if bubbleType == nil {
                bubbleType = "default_blue"
            }
        }
        return bubbleType
    }
    
    class func setBubbleTypeLeft(bubbleType: String, left: Bool) {
        if left {
            UserDefaults.standard.set(bubbleType, forKey: "userLeftCustomerBubble")
        } else {
            UserDefaults.standard.set(bubbleType, forKey: "userRightCustomerBubble")
        }
        UserDefaults.standard.synchronize()
    }
    
    class func sizeTrans(size: CGSize) -> CGSize {
        var width: CGFloat
        var height: CGFloat
        let imgWidth = size.width
        let imgHeight = size.height
        let ratio = size.width / size.height
        
        if ratio >= 1 {
            width = imgWidth > MAX_CHAT_TEXT_WIDTH ? MAX_CHAT_TEXT_WIDTH : imgWidth
            height = imgWidth > MAX_CHAT_TEXT_WIDTH ? (imgHeight * MAX_CHAT_TEXT_WIDTH / imgWidth) : imgHeight
        } else {
            height = imgHeight > MAX_CHAT_TEXT_WIDTH ? MAX_CHAT_TEXT_WIDTH : imgHeight
            width = imgHeight > MAX_CHAT_TEXT_WIDTH ? (imgWidth * MAX_CHAT_TEXT_WIDTH / imgHeight) : imgWidth
        }
        
        return CGSize.init(width: width, height: height)
    }
}
