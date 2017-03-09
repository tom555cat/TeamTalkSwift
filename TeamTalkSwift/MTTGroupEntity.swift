//
//  MTTGroupEntity.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/23.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

let GROUP_PRE = "group_"

class MTTGroupEntity: MTTBaseEntity {
    
    func copyContent(entity: MTTGroupEntity) {
        self.groupType = entity.groupType
        self.lastUpdateTime = entity.lastUpdateTime
        self.name = entity.name
        self.avatar = entity.avatar
        self.groupUserIds = entity.groupUserIds
    }
    
    class func localGroupIDtopb(groupID: String) -> UInt32 {
        if !groupID.hasPrefix(GROUP_PRE) {
            return 0
        }
        return UInt32(groupID.substring(from: groupID.index(groupID.startIndex, offsetBy: 4)).characters.count)
    }
    
    class func pbGroupIdToLocalID(groupID: UInt32) -> String {
        return String.init(format: "%@%ld", GROUP_PRE, groupID)
    }
    
    func addFixOrderGroupUserIDS(ID: String) {
        if self.fixGroupUserIds == nil {
            self.fixGroupUserIds = [String]()
        }
        self.fixGroupUserIds?.append(ID)
    }
    
    class func dicToMTTGroupEntity(dic: [String: Any]) -> MTTGroupEntity {
        let group = MTTGroupEntity()
        group.groupCreatorId = dic["creatID"] as! String
        group.objID = dic["groupId"] as? String
        group.avatar = dic["avatar"] as! String
        group.groupType = dic["groupType"] as! Int
        group.name = dic["name"] as! String
        group.isShield = dic["isshield"] as! Bool
        
        let string = dic["Users"] as! String
        let array = NSMutableArray.init(array: string.components(separatedBy: "-"))
        if array.count > 0 {
            for item in array {
                group.groupUserIds?.append(item as! String)
            }
        }
        group.lastMsg = dic["lastMessage"] as! String
        group.objectVersion = dic["version"] as! Int
        group.lastUpdateTime = dic["lastUpdateTime"] as! Int32
        return group
    }
    
    class func getSessionId(groupId: String) -> String {
        return groupId
    }
    
    class func initMTTGroupEntityFromPBData(groupInfo: IM_BaseDefine_GroupInfo) -> MTTGroupEntity {
        let group = MTTGroupEntity()
        group.objID = pbGroupIdToLocalID(groupID: groupInfo.groupId)
        group.objectVersion = Int(groupInfo.version)
        group.name = groupInfo.groupName
        group.avatar = groupInfo.groupAvatar
        group.groupCreatorId = MTTUtil.changeOriginalToLocalID(originalID: groupInfo.groupCreatorId, sessionType: IM_BaseDefine_SessionType.single)
        group.groupType = groupInfo.groupType.rawValue
        // 自己的猜测
        if groupInfo.shieldStatus == 0 {
            group.isShield = false
        } else {
            group.isShield = true
        }
        var ids = [String]()
        for i in 0..<groupInfo.groupMemberList.count {
            ids.append(MTTUtil.changeOriginalToLocalID(originalID: groupInfo.groupMemberList[i], sessionType: IM_BaseDefine_SessionType.single))
        }
        group.groupUserIds = ids
        group.lastMsg = ""
        return group
    }
    
    enum GroupType: Int {
        case GROUP_TYPE_FIXED = 1                   // 固定群
        case GROUP_TYPE_TEMPORARY = 2               // 临时群
    }
    
    var groupCreatorId: String = ""                 // 群创建者ID
    var groupType: Int = 0                          // 群类型
    var name: String = ""                           // 群名称
    var avatar: String = ""                         // 群头像
    var groupUserIds: [String]?                     // 群用户列表ids
    var fixGroupUserIds: [String]?                  // 固定的群用户列表IDS
    var lastMsg: String = ""
    var isShield: Bool = false
    
}
