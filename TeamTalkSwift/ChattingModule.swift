//
//  ChattingModule.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/29.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation
import SDWebImage

let DD_PAGE_ITEM_COUNT = 20

let showPromptGap: TimeInterval = 300

typealias DDReuestServiceCompletion = (MTTUserEntity) -> Void

typealias DDRequestGoodDetailCompletion = ([String: Any], NSError?) -> Void

typealias DDChatLoadMoreHistoryCompletion = (UInt32, NSError?) -> Void

class ChattingModule {
    var MTTSessionEntity: MTTSessionEntity?
    var ids: [UInt32] = [UInt32]()
    var showingMessages: [Any] = [MTTMessageEntity]()
    var isGroup: Int = 0
    
    private var textCell: DDChatTextCell?
    private var earliestDate: TimeInterval = 0.0
    private var latestDate: TimeInterval = 0.0
    
    /**
     *  加载历史消息接口，这里会适时插入时间
     *
     *  @param completion 加载完成
     *
     *  原名叫 loadMoreHistoryCompletion
     */
    func loadMoreHistory(loadMoreHistoryCompletion: @escaping DDChatLoadMoreHistoryCompletion) {
        let count = self.p_getMessageCount()
        
        MTTDatabaseUtil.sharedInstance.loadMessage(sessionID: (self.MTTSessionEntity?.sessionID)!, pagecount: DD_PAGE_ITEM_COUNT, index: count) { (messages: Array<MTTMessageEntity>, error: Error?) in
            
            if DDClientState.sharedInstance.networkState == .DDNetWorkDisconnect {
                self.p_addHistoryMessages(messages: messages, loadMoreHistoryCompletion: loadMoreHistoryCompletion)
            } else {
                if messages.count != 0 {
                    let isHaveMissMsg = self.p_isHaveMissMsg(messages: messages)
                    if (isHaveMissMsg || (self.getMiniMsgId() != self.getMaxMsgId(array: messages))) {
                        // 如果有缺失的消息，则从服务器端再重新获取
                        // 就我认为，loadMoreHistoryFromServerCompletion不需要对addCount进行判断，直接再p_addHistoryMessages就行
                        self.loadHistoryMessageFromServer(fromMsgID: self.getMiniMsgId(), loadMoreHistoryFromServerCompletion: { (addCount: UInt32, error: NSError?) in
                            if addCount > 0 {
                                loadMoreHistoryCompletion(addCount, error)
                            } else {
                                self.p_addHistoryMessages(messages: messages, loadMoreHistoryCompletion: loadMoreHistoryCompletion)
                            }
                        })
                        
                    } else {
                        // 检查消息是否连续
                        self.p_addHistoryMessages(messages: messages, loadMoreHistoryCompletion: loadMoreHistoryCompletion)
                    }
                } else {
                    // 数据库中已经获取不到消息
                    // 拿出当前最小的msgID去服务器端获取
                    self.loadHistoryMessageFromServer(fromMsgID: self.getMiniMsgId(), loadMoreHistoryFromServerCompletion: { (addCount: UInt32, error: NSError?) in
                        loadMoreHistoryCompletion(addCount, error)
                    })
                }
            }
        }
    }
    
    func loadAllHistoryCompletion(message: MTTMessageEntity, completion: @escaping DDChatLoadMoreHistoryCompletion) {
        MTTDatabaseUtil.sharedInstance.loadMessage(sessionID: (self.MTTSessionEntity?.sessionID)!, afterMessage: message) { (messages: Array<MTTMessageEntity>, error: Error?) in
            self.p_addHistoryMessages(messages: messages, loadMoreHistoryCompletion: completion)
        }
    }
    
    func loadHistoryUntilCommodity(message: MTTMessageEntity, completion: DDChatLoadMoreHistoryCompletion) {
        
    }
    
    func messageHeight(message: MTTMessageEntity) -> Float {
        if message.msgContentType == .DDMessageTypeText {
            if self.textCell == nil {
                self.textCell = DDChatTextCell.init(style: .default, reuseIdentifier: "DDChatTextCell")
            }
            return (textCell?.cellHeightForMessage(message: message))!
            
        } else if message.msgContentType == .DDMessageTypeVoice {
            
            return 60
            
        } else if message.msgContentType == .DDMessageTypeImage {
            
            var height = 150
            var urlString = message.msgContent
            urlString = urlString.replacingOccurrences(of: DD_MESSAGE_IMAGE_PREFIX, with: "")
            urlString = urlString.replacingOccurrences(of: DD_MESSAGE_IMAGE_SUFFIX, with: "")
            let url = URL.init(string: urlString)
            
            // 从SDWebImage中根据URL获取保存在本地的图片
            let manager = SDWebImageManager.shared()
            if (manager?.cachedImageExists(for: url))! {
                let key = manager?.cacheKey(for: url)
                let curImg = SDImageCache.shared().imageFromDiskCache(forKey: key)
                height = Int(MTTUtil.sizeTrans(size: (curImg?.size)!).height)
            }
            let last_height = height + 20
            return Float(last_height > 60 ? last_height : 60)
            
        } else if message.msgContentType == .DDMessageEmotion {
            
            return 133 + 20
            
        } else {
            
            return 135
            
        }
    }
    
    func addPrompt(promptContent: String) {
        let prompt = DDPromptEntity.init()
        prompt.message = promptContent
        self.showingMessages.append(prompt)
    }
    
    func addShowMessage(message: MTTMessageEntity) {
        if !self.ids.contains(message.msgID) {
            // 如果新消息时间大于之前最后消息时间一定程度，再增添一条prompt消息
            if message.msgTime - self.latestDate > showPromptGap {
                self.latestDate = message.msgTime
                let prompt = DDPromptEntity()
                let date = Date.init(timeIntervalSince1970: message.msgTime)
                prompt.message = date.description    // 这个还需要自己改
                self.showingMessages.append(prompt)
            }
            
            let array = ChattingModule.p_spliteMessage(message: message)
            for obj in array {
                DDLog(obj.msgContent)
                self.showingMessages.append(obj)
            }
        }
    }
    
    func addShowMessages(messages: [MTTMessageEntity]) {
        for obj in messages {
            self.showingMessages.append(obj)
        }
    }
    
    func scanDBAndFixIDList(closure: (Bool) -> Void) {
        
    }
    
    func updateSessionUpdateTime(time: TimeInterval) {
        self.MTTSessionEntity?.updateUpdateTime(date: time)
        self.latestDate = time
    }
    
    func clearChatData() {
        fatalError("还需要")
    }
    
    func m_clearScanRecord() {
        fatalError("还需要")
    }
    
    func showMessagesAddCommodity(message: MTTMessageEntity) {
        fatalError("还需要")
    }
    
    func getCurrentUser(closure: @escaping (MTTUserEntity) -> Void) {
        DDUserModule.sharedInstance.getUserFor(userID: (self.MTTSessionEntity?.sessionID)!) { (user: MTTUserEntity?) in
            closure(user!)
        }
    }
    
    func loadHistoryMessageFromServer(fromMsgID msgID: UInt32, loadCount count: UInt32, loadMoreHistoryFromServerCompletion: @escaping DDChatLoadMoreHistoryCompletion) {
        if self.MTTSessionEntity != nil {
            if msgID != 1 {
                DDMessageModule.sharedInstance.getMessageFromServer(fromMsgID: msgID, session: self.MTTSessionEntity!, count: count, block: { (response: [MTTMessageEntity], error: NSError?) in
                    
                    let msgID = self.getMaxMsgId(array: response)
                    if msgID != 0 {
                        MTTDatabaseUtil.sharedInstance.insertMessage(messageArray: response, success: {
                            let readACK = MsgReadACKAPI()
                            readACK.requestWithObject(object: [self.MTTSessionEntity?.sessionID, msgID, self.MTTSessionEntity?.sessionType.rawValue], completion: { (response: Any?, error: Error?) in
                                // 什么都不做
                            })
                        }, failure: { (String) in
                            // 什么都不做
                        })
                        
                        let count = self.p_getMessageCount()
                        MTTDatabaseUtil.sharedInstance.loadMessage(sessionID: (self.MTTSessionEntity?.sessionID)!, pagecount: DD_PAGE_ITEM_COUNT, index: count, completion: { (messages: Array<MTTMessageEntity>, error: NSError?) in
                            self.p_addHistoryMessages(messages: messages, loadMoreHistoryCompletion: loadMoreHistoryFromServerCompletion)
                            loadMoreHistoryFromServerCompletion(UInt32(response.count), error)
                        })
                        
                    } else {
                        loadMoreHistoryFromServerCompletion(0, nil)
                    }
                })
            }
        }
    }
    
    func loadHistoryMessageFromServer(fromMsgID msgID: UInt32, loadMoreHistoryFromServerCompletion: @escaping DDChatLoadMoreHistoryCompletion) {
        self.loadHistoryMessageFromServer(fromMsgID: msgID, loadCount: 19, loadMoreHistoryFromServerCompletion: loadMoreHistoryFromServerCompletion)
    }
    
    func getNewMsg(completion: @escaping DDChatLoadMoreHistoryCompletion) {
        DDMessageModule.sharedInstance.getMessageFromServer(fromMsgID: 0, session: self.MTTSessionEntity!, count: 20) { (response: [MTTMessageEntity], error: NSError?) in
            let msgID = self.getMaxMsgId(array: response)
            if msgID != 0 {
                response.sorted(by: {$0.msgTime > $1.msgTime})
                MTTDatabaseUtil.sharedInstance.insertMessage(messageArray: response, success: {
                    let readACK = MsgReadACKAPI()
                    readACK.requestWithObject(object: [self.MTTSessionEntity?.sessionType, msgID, self.MTTSessionEntity?.sessionType.rawValue], completion: { (response: Any?, error: Error?) in
                        // 什么都不做
                    })
                }, failure: { (error: String) in
                    // 什么都不做
                })
                
                for item in response {
                    self.addShowMessage(message: item)
                }
                completion(UInt32(response.count), error)
                
            } else {
                completion(0 , error)
            }
        }
    }
    
    //MARK: Private Function
    private func p_getMessageCount() -> Int {
        var count = 0
        for obj in self.showingMessages {
            if obj is MTTMessageEntity {
                count += 1
            }
        }
        return count
    }
    
    private func p_getEarliestDate(messages: [MTTMessageEntity]) -> TimeInterval {
        var earliestTime: TimeInterval = messages[0].msgTime
        for message in messages {
            if message.msgTime < earliestTime {
                earliestTime = message.msgTime
            }
        }
        return earliestTime
    }
    
    private func p_addHistoryMessages(messages: [MTTMessageEntity], loadMoreHistoryCompletion: DDChatLoadMoreHistoryCompletion) {
        let tempEarliestDate = self.p_getEarliestDate(messages: messages)
        var tempLatestDate: TimeInterval = 0
        let itemCount = self.showingMessages.count
        var tempMessages = [Any]()
        for message in messages.reversed() {
            
            if self.ids.contains(message.msgID) {
                continue
            }
            
            if message.msgTime - tempLatestDate > showPromptGap {
                let prompt = DDPromptEntity()
                let date = Date.init(timeIntervalSince1970: message.msgTime)
                prompt.message = date.description
                tempMessages.append(prompt)
            }
            tempLatestDate = message.msgTime
            //let array = DDMessageModule.sharedInstance.p_spliteMessage(message: message)
            let array = ChattingModule.p_spliteMessage(message: message)
            for obj in array {
                self.ids.append(message.msgID)
                tempMessages.append(obj)
            }
        }
        
        if self.showingMessages.count == 0 {
            self.showingMessages.append(contentsOf: tempMessages)
            self.earliestDate = tempEarliestDate
            self.latestDate = tempLatestDate
        } else {
            // 需要后续去调整
            //[self.showingMessages insertObjects:tempMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tempMessages count])]];
            self.showingMessages.removeFirst(tempMessages.count)
            self.showingMessages.insert(contentsOf: tempMessages, at: 0)
            self.earliestDate = tempEarliestDate
        }
        
        let newItemCount = self.showingMessages.count
        let gap = newItemCount - itemCount
        loadMoreHistoryCompletion(UInt32(gap), nil)
    }
    
    private func getMaxMsgId(array: [Any]) -> UInt32{
        var maxMsgID: UInt32 = 0
        for obj in array {
            if let message = obj as? MTTMessageEntity {
                if message.msgID > maxMsgID && message.msgID < LOCAL_MSG_BEGIN_ID {
                    maxMsgID = message.msgID
                }
            }
            
        }
        return maxMsgID
    }
    
    private func p_isHaveMissMsg(messages: [MTTMessageEntity]) -> Bool {
        let maxMsgID = self.getMaxMsgId(array: messages)
        var minMsgID = self.getMaxMsgId(array: messages)
        for obj in messages {
            if obj.msgID > maxMsgID && obj.msgID < LOCAL_MSG_BEGIN_ID {
                //
            } else if (obj.msgID < minMsgID) {
                minMsgID = obj.msgID
            }
        }
        
        let diff = maxMsgID - minMsgID
        if diff != 19 {
            return true             // 总共20条信息，最大值减去最小值是19
        } else {
            return false
        }
    }
    
    private func getMiniMsgId() -> UInt32 {
        if self.showingMessages.count == 0 {
            return (self.MTTSessionEntity?.lastMsgID)!
        }
        
        var minMsgID = self.getMaxMsgId(array: self.showingMessages)
        
        for obj in self.showingMessages {
            if let message = obj as? MTTMessageEntity {
                if message.msgID < minMsgID {
                    minMsgID = message.msgID
                }
            }
        }
        
        return minMsgID
    }
    
    private class func p_spliteMessage(message: MTTMessageEntity) -> [MTTMessageEntity] {
        message.msgContent = message.msgContent.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        var messageContentArray = [MTTMessageEntity]()
        
        if message.msgContent.range(of: DD_MESSAGE_IMAGE_PREFIX) != nil {
            
            let messageContent = message.msgContent
            if messageContent.range(of: DD_MESSAGE_IMAGE_PREFIX) != nil && messageContent.range(of: DD_IMAGE_LOCAL_KEY) != nil && messageContent.range(of: DD_IMAGE_URL_KEY) != nil {
                let messageEntity = MTTMessageEntity.init(ID: DDMessageModule.getMessageID(), msgType: message.msgType, msgTime: message.msgTime, sessionID: message.sessionId, senderID: message.senderId, msgContent: messageContent, toUserID: message.toUserID)
                messageEntity.msgContentType = .DDMessageTypeImage
                messageEntity.state = .DDMessageSendSuccess
                
            } else {
                
                let tempMessageContent = messageContent.components(separatedBy: DD_MESSAGE_IMAGE_PREFIX)
                for content in tempMessageContent {
                    if content.characters.count > 0 {
                        let suffixRange = content.range(of: DD_MESSAGE_IMAGE_SUFFIX)
                        if suffixRange != nil {
                            // 是图片，再拆分
                            let imageContent = String.init(format: "%@%@", DD_MESSAGE_IMAGE_PREFIX, content.substring(to: (suffixRange?.upperBound)!))
                            let messageEntity = MTTMessageEntity.init(ID: DDMessageModule.getMessageID(), msgType: message.msgType, msgTime: message.msgTime, sessionID: message.sessionId, senderID: message.senderId, msgContent: imageContent, toUserID: message.toUserID)
                            messageEntity.msgContentType = .DDMessageTypeImage
                            messageEntity.state = .DDMessageSendSuccess
                            messageContentArray.append(messageEntity)
                            
                            var secondComponent = content.substring(from: (suffixRange?.upperBound)!)
                            if secondComponent.characters.count > 0 {
                                let secondMessageEntity = MTTMessageEntity.init(ID: DDMessageModule.getMessageID(), msgType: message.msgType, msgTime: message.msgTime, sessionID: message.sessionId, senderID: message.senderId, msgContent: secondComponent, toUserID: message.toUserID)
                                secondMessageEntity.msgContentType = .DDMessageTypeText
                                secondMessageEntity.state = .DDMessageSendSuccess
                                messageContentArray.append(secondMessageEntity)
                            }
                            
                        } else {
                            
                            let messageEntity = MTTMessageEntity.init(ID: DDMessageModule.getMessageID(), msgType: message.msgType, msgTime: message.msgTime, sessionID: message.sessionId, senderID: message.senderId, msgContent: content, toUserID: message.toUserID)
                            messageEntity.state = .DDMessageSendSuccess
                            messageContentArray.append(messageEntity)
                        }
                    }
                }
            }
        }
        
        if messageContentArray.count == 0 {
            messageContentArray.append(message)
        }
        
        return messageContentArray
    }
}

class DDPromptEntity {
    var message: String?
}
