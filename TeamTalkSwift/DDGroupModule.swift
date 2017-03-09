//
//  DDGroupModule.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/14.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

typealias GetGroupInfoCompletion = (MTTGroupEntity) -> Void

class DDGroupModule {
    
    init() {
        self.allGroups = [String: MTTGroupEntity]()
        MTTDatabaseUtil.sharedInstance.loadGroupsCompletion { (contacts: Array<Any>, error: Error?) in
            for (_, value) in contacts.enumerated() {
                if let group = value as? MTTGroupEntity {
                    if (group.objID != nil) {
                        self.addGroup(newGroup: group)
                        let request = GetGroupInfoAPI()
                        request.requestWithObject(object: [MTTUtil.changeIDToOriginal(sessionID: group.objID!), group.objectVersion], completion: { (response: Any?, error: Error?) in
                            if error == nil {
                                if let array = response as? [MTTGroupEntity] {
                                    if array.count > 0 {
                                        let group = array[0]
                                        self.addGroup(newGroup: group)
                                        MTTDatabaseUtil.sharedInstance.updateRecentGroup(group: group, completion: { (error: NSError?) in
                                            DDLog("insert group to database error!")
                                        })
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
        self.registerAPI()
    }
    
    func getGroup(byGroupID gID: String) -> MTTGroupEntity? {
        let entity = self.allGroups?[gID]
        return entity
    }
    
    func addGroup(newGroup: MTTGroupEntity) {
        self.allGroups?[newGroup.objID!] = newGroup
    }
    
    func getGroupInfo(groupID: String, completion: @escaping GetGroupInfoCompletion) {
        let group = self.getGroup(byGroupID: groupID)
        if group != nil {
            completion(group!)
        } else {
            let request = GetGroupInfoAPI()
            request.requestWithObject(object: [MTTUtil.changeIDToOriginal(sessionID: groupID)], completion: { (response: Any?, error: Error?) in
                if error != nil {
                    if let array = response as? [MTTGroupEntity] {
                        if array.count > 0 {
                            let group = array[0]
                            self.addGroup(newGroup: group)
                            MTTDatabaseUtil.sharedInstance.updateRecentGroup(group: group, completion: { (error: NSError?) in
                                DDLog("insert group to database error.")
                            })
                            completion(group)
                        }
                    }
                }
            })
        }
    }
    
    func getAllGroups() -> [MTTGroupEntity] {
        return Array(self.allGroups!.values)
    }
    
    func registerAPI() {
        let addMemeberAPI = DDReceiveGroupAddMemberAPI()
        _ = addMemeberAPI.registerAPIInAPIScheduleReceiveData { (object: Any, error: NSError?) in
            if error != nil {
                if let groupEntity = object as? MTTGroupEntity {
                    if (self.getGroup(byGroupID: groupEntity.objID!) != nil) {
                        // 自己本身就再组中
                    } else {
                        // 自己被添加进组中
                        groupEntity.lastUpdateTime = Int32(NSDate().timeIntervalSince1970)
                        DDGroupModule.sharedInstance.addGroup(newGroup: groupEntity)
                        NotificationCenter.default.post(name: DDNotificationRecentContactsUpdate, object: nil)
                    }
                }
            } else {
                DDLog("\(error?.domain)")
            }
        }
    }
    
    //MARK: Property
    static let sharedInstance = DDGroupModule()
    var recentGroupCount: Int = 0
    var allGroups: [String: MTTGroupEntity]?             // 所有群
    var allFixedGroup: [String: MTTGroupEntity]?         // 所有固定群列表
}
