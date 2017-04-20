//
//  MTTBubbleModule.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/24.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation
import UIKit

struct MTTBubbleContentInset {
    var top: Float = 0.0
    var left: Float = 0.0
    var bottom: Float = 0.0
    var right: Float = 0.0
}

struct MTTBubbleVoiceInset {
    var top: Float = 0.0
    var left: Float = 0.0
    var bottom: Float = 0.0
    var right: Float = 0.0
}

struct MTTBubbleStretchy {
    var left: Float = 0.0
    var top: Float = 0.0
}

class MTTBubbleConfig {
    var inset: MTTBubbleContentInset = MTTBubbleContentInset()
    var voiceInset: MTTBubbleVoiceInset = MTTBubbleVoiceInset()
    var stretchy:  MTTBubbleStretchy = MTTBubbleStretchy()
    var imgStretchy: MTTBubbleStretchy = MTTBubbleStretchy()
    var textColor: UIColor?
    var linkColor: UIColor?
    var textBgImage: String?
    var picBgImage: String?
    
    init(config: String, left: Bool) {
        var textBgImagePath: String?
        var picBgImagePath: String?
        
        do {
            let data = try Data.init(contentsOf: URL.init(fileURLWithPath: config))
            //let data = Data([UInt8](config.utf8))
            var dic = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
            var insetTemp: MTTBubbleContentInset = MTTBubbleContentInset()
            if let contentInset = dic["contentInset"] as? [String: Any] {
                insetTemp.top = contentInset["top"] as! Float
                insetTemp.bottom = contentInset["bottom"] as! Float
                if left {
                    insetTemp.left = contentInset["left"] as! Float
                    insetTemp.right = contentInset["right"] as! Float
                } else {
                    insetTemp.left = contentInset["right"] as! Float
                    insetTemp.right = contentInset["left"] as! Float
                }
                self.inset = insetTemp
            }
            
            var voiceInsetTemp: MTTBubbleVoiceInset = MTTBubbleVoiceInset()
            if let voiceInset = dic["voiceInset"] as? [String: Any] {
                voiceInsetTemp.top = voiceInset["top"] as! Float
                voiceInsetTemp.bottom = voiceInset["bottom"] as! Float
                if left {
                    voiceInsetTemp.left = voiceInset["left"] as! Float
                    voiceInsetTemp.right = voiceInset["right"] as! Float
                } else {
                    voiceInsetTemp.left = voiceInset["right"] as! Float
                    voiceInsetTemp.right = voiceInset["left"] as! Float
                }
                self.voiceInset = voiceInsetTemp
            }
            
            var stretchyTemp: MTTBubbleStretchy = MTTBubbleStretchy()
            if let stretchDic = dic["stretchy"] as? [String: Any] {
                stretchyTemp.left = stretchDic["left"] as! Float
                stretchyTemp.top = stretchDic["top"] as! Float
                self.stretchy = stretchyTemp
            }
            
            var imgStretchyTemp: MTTBubbleStretchy = MTTBubbleStretchy()
            if let imgStretchyDic = dic["imgStretchy"] as? [String: Any] {
                imgStretchyTemp.left = imgStretchyDic["left"] as! Float
                imgStretchyTemp.top = imgStretchyDic["top"] as! Float
                self.imgStretchy = imgStretchyTemp
            }
            
            var textColorTemp = (dic["textColor"] as! String).components(separatedBy: ",")
            self.textColor = RGB(Int(textColorTemp[0])!, Int(textColorTemp[1])!, Int(textColorTemp[2])!)
            
            let linkColorTemp = (dic["linkColor"] as! String).components(separatedBy: ",")
            self.linkColor = RGB(Int(linkColorTemp[0])!, Int(linkColorTemp[1])!, Int(linkColorTemp[2])!)
            
            let bubbleType = MTTUtil.getBubbleTypeLeft(left: left)
            if left {
                textBgImagePath = String.init(format: "bubble.bundle/%@/textLeftBubble", bubbleType!)
                picBgImagePath = String.init(format: "bubble.bundle/%@/picLeftBubble", bubbleType!)
            } else {
                textBgImagePath = String.init(format: "bubble.bundle/%@/textBubble", bubbleType!)
                picBgImagePath = String.init(format: "bubble.bundle/%@/picBubble", bubbleType!)
            }
            
            self.textBgImage = textBgImagePath!
            self.picBgImage = picBgImagePath!
            
        } catch {
            DDLog("读取JSON文件出错! 或 JSON转字典出错!")
        }
    }
}

class MTTBubbleModule {
    
    static let sharedInstance = MTTBubbleModule()
    
    private var left_config: MTTBubbleConfig
    
    private var right_config: MTTBubbleConfig
    
    init() {
        let leftBubbleType = MTTUtil.getBubbleTypeLeft(left: true)
        let rightBubbleType = MTTUtil.getBubbleTypeLeft(left: false)
        let leftBubblePath = String.init(format: "bubble.bundle/%@/config.json", leftBubbleType!)
        let rightBubblePath = String.init(format: "bubble.bundle/%@/config.json", rightBubbleType!)
        let leftPath = URL.init(string: Bundle.main.resourcePath!)?.appendingPathComponent(leftBubblePath).absoluteString
        let rightPath = URL.init(string: Bundle.main.resourcePath!)?.appendingPathComponent(rightBubblePath).absoluteString
        
        left_config = MTTBubbleConfig.init(config: leftPath!, left: true)
        right_config = MTTBubbleConfig.init(config: rightPath!, left: false)
    }
    
    func getBubbleConfigLeft(left: Bool) -> MTTBubbleConfig {
        if left {
            return left_config
        } else {
            return right_config
        }
    }
    
    func selectBubbleTheme(bubbleType: String, left: Bool) {
        MTTUtil.setBubbleTypeLeft(bubbleType: bubbleType, left: left)
        let path = String.init(format: "bubble.bundle/%@/config.json", bubbleType)
        let realPath = URL.init(string: Bundle.main.resourcePath!)?.appendingPathComponent(path).absoluteString
        if left {
            left_config = MTTBubbleConfig.init(config: realPath!, left: left)
        } else {
            right_config = MTTBubbleConfig.init(config: realPath!, left: left)
        }
    }
}
