//
//  DictionaryExtension.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/4/5.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

extension Dictionary {
    func jsonString() -> String? {
        do {
            let infoJsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            let json = String.init(data: infoJsonData, encoding: .utf8)
            return json
        } catch {
            DDLog("字典转JSON失败")
            return nil
        }
        
    }
    
}
