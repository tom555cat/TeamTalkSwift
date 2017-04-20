//
//  DDMessageSendManager.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/27.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

typealias DDSendMessageCompletion = (MTTMessageEntity?, NSError?) -> Void

enum MessageType : Int {
    case allString
    case hasImage
}

struct MessageSeqNo {
    static var seqNo: UInt32 = 0
}

class DDMessageSendManager {
    var sendMessageSendQueue: DispatchQueue?
    var waitToSendMessage: [Any]?
    static let sharedInstance = DDMessageSendManager()
    
    private var uploadImageCount: UInt = 0
    
    init() {
        self.uploadImageCount = 0
        self.waitToSendMessage = [Any]()
        self.sendMessageSendQueue = DispatchQueue.init(label: "com.mogujie.Duoduo.sendMessageSend")
    }
    
    func sendMessage(message: MTTMessageEntity, isGroup: Bool, session: MTTSessionEntity, completion: @escaping DDSendMessageCompletion, closure: @escaping (NSError)->Void) {
        self.sendMessageSendQueue?.async {
            
            MessageSeqNo.seqNo += 1
            let nowSeqNo = MessageSeqNo.seqNo
            
            var newContent = message.msgContent
            if message.isImageMessage() {
                let dic = MTTUtil.jsonStringToDictionary(text: message.msgContent)
                let urlPath = dic?[DD_IMAGE_URL_KEY]
                newContent = urlPath as! String
            }
            
            // 我们不进行加密...
            let encodeDataArray = [UInt8](newContent.utf8)
            let data = Data(encodeDataArray)
            
            if message.msgID == 0 {
                return
            }
            let object: [Any] = [RuntimeStatus.sharedInstance.user?.objID, session.sessionID, data, message.msgType, message.msgID]
            if message.isImageMessage() {
                session.lastMsg = "[图片]"
            } else if message.isVoiceMessage() {
                session.lastMsg = "[语言]"
            } else {
                session.lastMsg = message.msgContent
            }
            
            UnAckMessageManager.sharedInstance.addMessageToUnAckQueue(message: message)
            NotificationCenter.default.post(name: NSNotification.Name("SentMessageSuccessfull"), object: session)
            
            let sendMessageAPI = SendMessageAPI()
            sendMessageAPI.requestWithObject(object: object, completion: { (response: Any?, error: NSError?) in
                if error == nil {
                    if let array = response as? [Any] {
                        DDLog("消息发送成功!")
                        MTTDatabaseUtil.sharedInstance.deleteMessage(message: message, completion: { (success: Bool) in
                            // 什么都不做
                        })
                        
                        UnAckMessageManager.sharedInstance.removeMessageFromUnAckQueue(message: message)
                        message.msgID = array[0] as! UInt32
                        message.state = .DDMessageSendSuccess
                        session.lastMsgID = message.msgID
                        session.timeInterval = message.msgTime
                        NotificationCenter.default.post(name: NSNotification.Name("SentMessageSuccessfull"), object: session)
                        MTTDatabaseUtil.sharedInstance.insertMessage(messageArray: [message], success: {
                            // 什么都不做
                        }, failure: { (errorDescription: String) in
                            // 什么都不做
                        })
                        completion(message, nil)
                    }
                } else {
                    message.state = .DDMessageSendFailure
                    MTTDatabaseUtil.sharedInstance.insertMessage(messageArray: [message], success: {
                        // 什么都不做
                    }, failure: { (errorDescription: String) in
                        // 什么都不做
                    })
                    
                    let error = NSError.init(domain: "发送消息失败", code: 0, userInfo: nil)
                    closure(error)
                }
            })
        }
    }
    
    func sendVoiceMessage(voice: Data, filePath: String, forSessionID sessionID: String, isGroup: Bool, msg: MTTMessageEntity, session: MTTSessionEntity, completion: @escaping DDSendMessageCompletion) {
        self.sendMessageSendQueue?.async {
            let sendVoiceMessageAPI = SendMessageAPI()
            let myUserID = RuntimeStatus.sharedInstance.user?.objID
            let object = [myUserID!, sessionID, voice, msg.msgType, 0] as [Any]
            
            sendVoiceMessageAPI.requestWithObject(object: object, completion: { (response: Any?, error: NSError?) in
                if error == nil {
                    if let array = response as? [Any] {
                        DDLog("发送消息成功")
                        MTTDatabaseUtil.sharedInstance.deleteMessage(message: msg, completion: { (success: Bool) in
                            // 什么都不做
                        })
                        
                        let messageTime = Date.timeIntervalBetween1970AndReferenceDate
                        msg.msgTime = messageTime
                        msg.msgID = array[0] as! UInt32
                        msg.state = .DDMessageSendSuccess
                        session.lastMsg = "[语音]"
                        session.lastMsgID = msg.msgID
                        session.timeInterval = msg.msgTime
                        NotificationCenter.default.post(name: NSNotification.Name("SentMessageSuccessfull"), object: session)
                        MTTDatabaseUtil.sharedInstance.insertMessage(messageArray: [msg], success: {
                            // 什么都不做
                        }, failure: { (errorDescription: String) in
                            // 什么
                        })
                        
                        completion(msg, nil)
                    }
                    
                } else {
                    let error = NSError.init(domain: "发送消息失败", code: 0, userInfo: nil)
                    completion(nil, error)
                }
                
            })
        }
    }
}
