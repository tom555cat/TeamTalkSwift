//
//  DDMessageModule.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/22.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class DDMessageModule {
    
    init() {
        self.unReadMsgCount = 0
        self.unReadMessages = [String: Any]()
        self.p_registerReceiveMessageAPI()
    }
    
    class func getMessageID() -> UInt32 {
        var messageID = UserDefaults.standard.integer(forKey: "msg_id")
        if messageID == 0 {
            messageID = Int(LOCAL_MSG_BEGIN_ID)
        } else {
            messageID += 1
        }
        UserDefaults.standard.set(messageID, forKey: "msg_id")
        UserDefaults.standard.synchronize()
        return UInt32(messageID)
    }
    
    func removeFromUnreadMessageButNotSendRead(sessionID: String) {
    
    }
    
    func removeAllUnreadMessages() {
        self.unReadMessages.removeAll()
    }
    
    func getUnreadMessageCount() -> UInt {
        let count = 0
        // 这个看不出来返回了什么
        return UInt(count)
    }
    
    func sendMsgRead(message: MTTMessageEntity) {
        let readACK = MsgReadACKAPI()
        readACK.requestWithObject(object: [message.sessionId, message.msgID, message.sessionType]) { (_: Any?, _: Error?) in
            // 什么都不做
        }
    }
    
    func getMessageFromServer(fromMsgID: UInt32, session: MTTSessionEntity, count: UInt32, block: @escaping ([MTTMessageEntity], NSError?)->Void) {
        let getMessageQueue = GetMessageQueueAPI()
        getMessageQueue.requestWithObject(object: [fromMsgID, count, session.sessionType.rawValue, session.sessionID]) { (response: Any?, error: NSError?) in
            block(response as! [MTTMessageEntity], error)
        }
    }
    
    //MARK: Private function
    func p_registerReceiveMessageAPI() {
        let receiveMessageAPI = DDReceiveMessageAPI()
        _ = receiveMessageAPI.registerAPIInAPIScheduleReceiveData { (object: Any, error: NSError?) in
            if let message = object as? MTTMessageEntity {
                message.state = .DDmessageSendSuccess
                let rmack = DDReceiveMessageACKAPI()
                rmack.requestWithObject(object: [message.senderId, message.msgID, message.sessionId, message.sessionType], completion: { (object: Any?, error: Error?) in
                    // 什么都不做
                })
                _ = self.p_spliteMessage(message: message)
                
                if message.isGroupMessage() {
                    let group = DDGroupModule.sharedInstance.getGroup(byGroupID: message.sessionId)
                    if group?.isShield == true {
                        let readACK = MsgReadACKAPI()
                        readACK.requestWithObject(object: [message.sessionId, message.msgID, message.sessionType], completion: { (object: Any?, error: Error?) in
                            // 什么都不做
                        })
                    }
                }
                MTTDatabaseUtil.sharedInstance.insertMessage(messageArray: [message], success: {
                    // 什么都不做
                }, failure: { (str: String) in
                    // 什么都不做
                })
                MTTNotification.postNotification(notification: DDNotificationReceiveMessage, userInfo: nil, object: message)
            }
        }
    }
    
    func p_spliteMessage(message: MTTMessageEntity) -> [MTTMessageEntity] {
        var messageContentArray = [MTTMessageEntity]()
        if message.msgContentType == .DDMessageTypeImage || (message.msgContentType == .DDMessageTypeText &&
            message.msgContent.range(of: DD_MESSAGE_IMAGE_PREFIX) != nil) {
            let messageContent = message.msgContent
            var tempMessageContent = messageContent.components(separatedBy: DD_MESSAGE_IMAGE_PREFIX)
            for (_, value) in tempMessageContent.enumerated() {
                let content = value 
                if content.characters.count > 0 {
                    let suffixRange = content.range(of: DD_MESSAGE_IMAGE_PREFIX)
                    if  suffixRange != nil {
                        // 是图片，再拆分
                        let imageContent = String.init(format: "%@%@", DD_MESSAGE_IMAGE_PREFIX, content.substring(with: content.startIndex..<(suffixRange?.upperBound)!))
                        let messageEntity = MTTMessageEntity.init(ID: DDMessageModule.getMessageID(), msgType: message.msgType, msgTime: message.msgTime, sessionID: message.sessionId, senderID: message.senderId, msgContent: imageContent, toUserID: message.toUserID)
                        messageEntity.msgContentType = .DDMessageTypeImage
                        messageEntity.state = .DDmessageSendSuccess
                        messageContentArray.append(messageEntity)
                        
                        let secondComponent = content.substring(with: (suffixRange?.upperBound)!..<content.endIndex)
                        if secondComponent.characters.count > 0 {
                            let secondMessageEntity = MTTMessageEntity.init(ID: DDMessageModule.getMessageID(), msgType: message.msgType, msgTime: message.msgTime, sessionID: message.sessionId, senderID: message.senderId, msgContent: secondComponent, toUserID: message.toUserID)
                            secondMessageEntity.msgContentType = .DDMessageTypeText
                            secondMessageEntity.state = .DDmessageSendSuccess
                            messageContentArray.append(secondMessageEntity)
                        }
                    } else {
                        let messageEntity = MTTMessageEntity.init(ID: DDMessageModule.getMessageID(), msgType: message.msgType, msgTime: message.msgTime, sessionID: message.sessionId, senderID: message.senderId, msgContent: content, toUserID: message.toUserID)
                        messageEntity.msgContentType = .DDMessageTypeText
                        messageEntity.state = .DDmessageSendSuccess
                        messageContentArray.append(messageEntity)
                    }
                }
            }
        }
        
        if messageContentArray.count == 0 {
            messageContentArray.append(message)
        }
        
        return messageContentArray
    }
    
    //MARK: Property
    static let sharedInstance = DDMessageModule()
    var unReadMsgCount: Int
    
    private var unReadMessages: [String: Any]
}
