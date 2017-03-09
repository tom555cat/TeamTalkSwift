//
//  EmotionsModule.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/14.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class EmotionsModule {
    //MARK: Function
    init() {
        self.emotionUnicodeDic = [
            "[牙牙撒花]":"emotions.bundle/221.gif",
            "[牙牙尴尬]":"emotions.bundle/222.gif",
            "[牙牙大笑]":"emotions.bundle/223.gif",
            "[牙牙组团]":"emotions.bundle/224.gif",
            "[牙牙凄凉]":"emotions.bundle/225.gif",
            "[牙牙吐血]":"emotions.bundle/226.gif",
            "[牙牙花痴]":"emotions.bundle/227.gif",
            "[牙牙疑问]":"emotions.bundle/228.gif",
            "[牙牙爱心]":"emotions.bundle/229.gif",
            "[牙牙害羞]":"emotions.bundle/230.gif",
            "[牙牙牙买碟]":"emotions.bundle/231.gif",
            "[牙牙亲一下]":"emotions.bundle/232.gif",
            "[牙牙大哭]":"emotions.bundle/233.gif",
            "[牙牙愤怒]":"emotions.bundle/234.gif",
            "[牙牙挖鼻屎]":"emotions.bundle/235.gif",
            "[牙牙嘻嘻]":"emotions.bundle/236.gif",
            "[牙牙漂漂]":"emotions.bundle/237.gif",
            "[牙牙冰冻]":"emotions.bundle/238.gif",
            "[牙牙傲娇]":"emotions.bundle/239.gif"
        ]
        
        self.unicodeEmotionDic = [String: Any]()
        for (key, value) in self.emotionUnicodeDic! {
            self.unicodeEmotionDic?[key] = value
        }
        self.emotions = Array((self.emotionUnicodeDic?.keys)!)
        self.emotionLength = [String: Any]()
        for (_, value) in (self.emotions?.enumerated())! {
            if let str = value as? String {
                let string = self.emotionUnicodeDic?[str] as? String
                self.emotionLength?[str] = string?.characters.count
            }
        }
    }
    
    //MARK: Property
    static let sharedInstance = EmotionsModule()
    var emotions: [Any]?                        // 表情名字数组
    var emotionUnicodeDic: [String: Any]?       // 表情名字: 表情文件路径
    var unicodeEmotionDic: [String: Any]?       // 表情名字: 表情文件路径
    var emotionLength: [String: Any]?           // 表情名字: 表情文件路径长度
}
