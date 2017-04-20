//
//  ContactsModule.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/4/14.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class ContactsModule {
    
    var groups = [MTTGroupEntity]()
    var contactsCount: Int = 0
    
    // 按首字母展示
    func sortByContactPy() -> [String: [MTTUserEntity]] {
        var dic = [String: [MTTUserEntity]]()
        for user in DDUserModule.sharedInstance.getAllMaintenance() {
            let startIndex = (user.pyname?.startIndex)!
            let endIndex = (user.pyname?.index(after: startIndex))!
            let fl = user.pyname?.substring(with: startIndex..<endIndex)
            if dic.keys.contains(fl!) {
                dic[fl!]?.append(user)
            } else {
                var arr = [MTTUserEntity]()
                arr.append(user)
                dic[fl!] = arr
            }
        }
        
        for (key, preData) in dic {
            let tmp = preData.sorted(by: { (a: MTTUserEntity, b: MTTUserEntity) -> Bool in
                if a.pyname! > b.pyname! {
                    return true
                } else {
                    return false
                }
            })
            dic[key] = tmp
        }
        
        return dic
    }
    
    // 按部门分类展示
    func sortByDepartment() -> [String: [MTTUserEntity]] {
        var dic = [String: [MTTUserEntity]]()
        for user in DDUserModule.sharedInstance.getAllMaintenance() {
            if dic.keys.contains(user.department!) {
                var arr = dic[user.department!]
                arr?.append(user)
            } else {
                var arr = [MTTUserEntity]()
                arr.append(user)
                dic[user.department!] = arr
            }
        }
        
        for (key, preData) in dic {
            let tmp = preData.sorted(by: { (a: MTTUserEntity, b: MTTUserEntity) -> Bool in
                if a.pyname! > b.pyname! {
                    return true
                } else {
                    return false
                }
            })
            dic[key] = tmp
        }
        
        return dic
    }
    
    // 收藏联系人
    class func favContact(user: MTTUserEntity) {
        if (UserDefaults.standard.value(forKey: "favuser") == nil) {
            UserDefaults.standard.set([MTTUserEntity.userToDic(user: user)], forKey: "favuser")
        } else {
            var arr = UserDefaults.standard.array(forKey: "favuser") as! [[String: Any]]
            if arr.count == 0 {
                arr.append(MTTUserEntity.userToDic(user: user))
                UserDefaults.standard.set(arr, forKey: "favuser")
                return
            }
            
            for i in 0..<arr.count {
                let dic = arr[i]
                if (dic["userId"] as! String) == user.objID {
                    arr.remove(at: i)
                    UserDefaults.standard.set(arr, forKey: "favuser")
                    return
                } else {
                    if i == arr.count - 1 {
                        arr.append(MTTUserEntity.userToDic(user: user))
                        UserDefaults.standard.set(arr, forKey: "favuser")
                        return
                    }
                }
            }
        }
    }
    
    // 获取本地收藏的联系人
    func getFavContact() -> [MTTUserEntity] {
        let arr = UserDefaults.standard.object(forKey: "favuser") as! [[String: Any]]
        var contacts = [MTTUserEntity]()
        for obj in arr {
            contacts.append(MTTUserEntity.dicToUserEntity(dic: obj))
        }
        return contacts
    }
    
    // 检查是否在收藏的联系人里
    func isInFavContactList(user: MTTUserEntity) -> Bool {
        let arr = UserDefaults.standard.object(forKey: "favuser") as! [[String: Any]]
        for dic in arr {
            if (dic["userId"] as! String) == user.objID {
                return true
            }
        }
        return false
    }
    
    class func getDepartmentData(closure: @escaping (Any?) -> Void) {
        let api = DMTTDepartmentAPI()
        api.requestWithObject(object: nil) { (response: Any?, error: NSError?) in
            if error == nil {
                if response != nil {
                    closure(response)
                } else {
                    closure(nil)
                }
                
            } else {
                DDLog("error: \(error?.domain)")
            }
        }
    }
}
