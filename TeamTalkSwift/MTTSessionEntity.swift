//
//  MTTSessionEntity.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/29.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class MTTSessionEntity {
    
    init(sessionID: String, type: IM_BaseDefine_SessionType) {
        self.sessionID = sessionID
        self.sessionType = type
        self.unReadMsgCount = 0
        self.lastMsg = ""
        self.timeInterval = Date.timeIntervalBetween1970AndReferenceDate
    }
    
    convenience init(sessionID: String, name: String, type: IM_BaseDefine_SessionType) {
        self.init(sessionID: sessionID, type: type)
        self.name = name
    }
    
    convenience init(user: MTTUserEntity) {
        self.init(sessionID: user.objID!, type: IM_BaseDefine_SessionType.single)
        self.name = user.name!
    }
    
    convenience init(group: MTTGroupEntity) {
        self.init(sessionID: group.objID!, type: IM_BaseDefine_SessionType.group)
        self.name = group.name
    }
    
    func updateUpdateTime(date: TimeInterval) {
        self.timeInterval = date
        MTTDatabaseUtil.sharedInstance.updateRecentSession(session: self) { (error: NSError?) in
            // 什么都不做
        }
    }
    
    
    func getSessionGroupID() -> String {
        return self.sessionID
    }
    
    func setSessionName(theName: String) {
        self.name = theName
    }
    
    func isGroup() -> Bool {
        if self.sessionType == .group {
            return true
        } else {
            return false
        }
    }
 
    var sessionID: String = ""
    var sessionType: IM_BaseDefine_SessionType
    var name: String = ""
    var unReadMsgCount: Int = 0
    var timeInterval: TimeInterval = 0
    var orginId: String = ""
    var isShield: Bool = false
    var isFixedTop: Bool = false
    var lastMsg: String?
    var lastMsgID: UInt32 = 0
    var avatar: String = ""
    var sessionUsers: [String]? {
        if sessionType == .group {
            let group = DDGroupModule.sharedInstance.getGroup(byGroupID: sessionID)
            return group?.groupUserIds
        } else {
            return nil
        }
    }
}
