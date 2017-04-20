//
//  MTTBaseEntity.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/4.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class MTTBaseEntity{

    var lastUpdateTime: Int32 = 0
    
    var objID: String?
    
    var objectVersion: UInt32 = 0
    
    func getOriginalID() -> UInt32 {
        let array = self.objID?.components(separatedBy: "_")
        if (array?.count)! >= 2 {
            return UInt32(array![1])!
        }
        return 0
    }
    
}
