//
//  SpellLibrary.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/9.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class SpellLibrary {
    
    init() {
        self.spellLibrary = [String: Any]()
        self.spellLibrary_Department = [String: Any]()
        self.saucerManDic = ["长卿" : "chang qing", "朝夕" : "zhao xi"]
    }
    
    /**
     *  清除所有数据
     */
    func clearAllSpell() {
    
    }
    
    func clearSpell(byId objectid: String) {
        self.spellLibrary.removeValue(forKey: objectid)
    }
    
    /**
     *  添加一个用户名称的拼音数据
     *
     *  @param sender user or group
     */
    func addSpell(forObject sender: Any) {
        var word: String?
        if let user = sender as? MTTUserEntity {
            word = user.nick
        } else if let group = sender as? MTTGroupEntity {
            word = group.name
        } else {
            return
        }
        if word == nil {
            return
        }
        
        var spell = self.saucerManDic[word!] as? String
        if spell != nil {
            spell = String.init(format: "%@", word!)
            CFStringTransform(NSMutableString(string: spell!), nil, kCFStringTransformMandarinLatin, false)
            CFStringTransform(NSMutableString(string: spell!), nil, kCFStringTransformStripCombiningMarks, false)
        }
        var key = spell?.lowercased()
        if Array(self.spellLibrary.keys).contains(spell!) {
            var objects = [Any]()
            objects.append(sender)
            self.spellLibrary[key!] = objects
        } else {
            var objects = self.spellLibrary[key!] as! [Any]
            
        }
    }
    
    func addDepartmentSpell(forObject sender: Any) {
        
    }
    
    func isEmpty() -> Bool {
        if Array(self.spellLibrary.keys).count > 0 {
            return false
        } else {
            return true
        }
    }
    
    /**
     *  根据给出拼音找出相关的用户名
     *
     *  @param spell 拼音
     */
    /*
    func checkoutForWords(forSpell spell: String) -> Array<Any> {
        
    }
    
    func checkoutForWords(forDepartmentSpell spell: String) -> Array<Any> {
        
    }
    */
    
    /**
     *  获得某个词的拼音
     *
     *  @param word 某个词
     *
     *  @return 词的拼音
     */
    /*
    func getSpell(forWord word: String) -> String {
        
    }
    */
    
    /**
     *  将拼音进行简全缩写
     *
     *  @param sender 完整拼音的数组
     *  @param count  完整拼音的个数
     *
     *  @return 结果
     */
    /*
    func briefSpellWord(fromSpellArray sender: Array<Any>, count: Int) -> String {
        
    }
    */
    
    //MARK: Property
    
    static let sharedInstance = SpellLibrary()
    
    private var spellLibrary: [String: Any]
    private var spellLibrary_Department: [String: Any]
    private var saucerManDic: [String: Any]
}
