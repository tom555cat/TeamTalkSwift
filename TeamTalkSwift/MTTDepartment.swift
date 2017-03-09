//
//  MTTDepartment.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/4.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class MTTDepartment {
    
    class func departmentFrom(dic: [String: Any]) -> MTTDepartment {
        let department = MTTDepartment()
        department.ID = dic["departID"] as! String
        department.title = dic["title"] as! String
        department.description = dic["description"] as! String
        department.leader = dic["leader"] as! String
        department.parentID = dic["parentID"] as! String
        department.status = dic["status"] as! Int
        department.count = dic["departCount"] as! Int
        return department
    }
    
    var ID: String = ""
    var parentID: String = ""
    var title: String = ""
    var description: String = ""
    var leader: String = ""
    var status: Int = 0
    var count: Int = 0
}
