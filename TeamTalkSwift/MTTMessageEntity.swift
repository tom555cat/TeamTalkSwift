//
//  MTTMessageEntity.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/22.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

let VOICE_LENGTH                    = "voiceLength"
let DDVOICE_PLAYED                  = "voicePlayed"

class MTTMessageEntity: NSObject {
    
    override init() {
        self.msgID = 0
        self.msgType = IM_BaseDefine_MsgType.singleText
        self.msgTime = 0
        self.sessionId = ""
        self.seqNo = 0
        self.senderId = ""
        self.msgContent = ""
        self.toUserID = ""
        self.info = [String: Any]()
        self.msgContentType = DDMessageContentType.DDMessageTypeText
        self.attach = ""
        self.sessionType = IM_BaseDefine_SessionType.single
        self.state = DDMessageState.DDMessageSendFailure
    }
    
    init(ID: UInt32,
         msgType: IM_BaseDefine_MsgType,
         msgTime: TimeInterval,
         sessionID: String,
         senderID: String,
         msgContent: String,
         toUserID: String)
    {
        self.msgID = ID
        self.msgType = msgType
        self.msgTime = msgTime
        self.sessionId = sessionID
        self.senderId = senderID
        self.msgContent = msgContent
        self.toUserID = toUserID
        self.info = [String: Any]()
    }
    
    /*  需要chattingModule
    class func makeMessage(content: String, C) -> MTTMessageEntity {
     
    }
    */
    
    /*
    class func makeMessageFromStream(bodyData: DDDataInputStream) -> MTTMessageEntity {
    
    }
    */
    
    class func makeMessageFromPB(info: IM_BaseDefine_MsgInfo, sessionType: IM_BaseDefine_SessionType) throws -> MTTMessageEntity {
        let msg = MTTMessageEntity()
        msg.msgType = info.msgType
        var msgInfo = [String: Any]()
        
        if msg.isVoiceMessage() {
            msg.msgContentType = DDMessageContentType.DDMessageTypeVoice
            let data = info.msgData
            var voiceData = Data()
            if data.count > 4 {
                voiceData = data.subdata(in: 0..<4)
                let filename = URL(fileURLWithPath: Encapsulator.defaultFileName())
                do {
                    try voiceData.write(to: filename)
                    msg.msgContent = Encapsulator.defaultFileName()
                } catch {
                    msg.msgContent = "语音存储出错"
                    DDLog("语音存储出错")
                }
                
                let voiceLengthData = data.subdata(in: 0..<4)
                
                var ch1 = UInt8()
                voiceLengthData.copyBytes(to: &ch1, from: 0..<1)
                ch1 = ch1 & 0x0ff
                
                var ch2 = UInt8()
                voiceLengthData.copyBytes(to: &ch2, from: 1..<2)
                ch2 = ch2 & 0x0ff
                
                var ch3 = UInt8()
                voiceLengthData.copyBytes(to: &ch3, from: 2..<3)
                ch3 = ch3 & 0x0ff
                
                var ch4 = UInt8()
                voiceLengthData.copyBytes(to: &ch4, from: 3..<4)
                ch4 = ch4 & 0x0ff
                
                if (ch1 | ch2 | ch3 | ch4) < 0 {
                    throw MessageError.endOfFile
                }
                
                let voiceLength = UInt32(ch1 << 24) + UInt32(ch2 << 16) + UInt32(ch3 << 8) + UInt32(ch4 << 0)
                msgInfo[VOICE_LENGTH] = voiceLength
                msgInfo[DDVOICE_PLAYED] = 1
            }
        } else {
            // 不对tempStr进行解密
            let tempStr = String.init(data: info.msgData, encoding: String.Encoding.utf8)
            msg.msgContent = tempStr!
            /*
            let nRet = DecryptMsg(tempStr, nInLen, &pOut, nOutLen)
            if nRet == 0 {
                msg.msgContent = String.init(data: pOut, encoding: String.Encoding.utf8)
            } else {
                msg.msgContent = ""
            }
             */
        }
        
        if MTTMessageEntity.isEmotionMsg(content: msg.msgContent) {
            msg.msgContentType = .DDMessageEmotion
        }
        
        msg.sessionId = MTTUtil.changeOriginalToLocalID(originalID: info.fromSessionId, sessionType: sessionType)
        msg.msgID = info.msgId
        msg.toUserID = (RuntimeStatus.sharedInstance.user?.objID)!
        msg.senderId = MTTUtil.changeOriginalToLocalID(originalID: info.fromSessionId, sessionType: IM_BaseDefine_SessionType.single)
        msg.msgTime = TimeInterval(info.createTime)
        msg.info = msgInfo
        return msg
    }
    
    class func makeMessageFromPBData(data: IM_Message_IMMsgData) throws -> MTTMessageEntity {
        let msg = MTTMessageEntity()
        msg.msgType = data.msgType
        let type = msg.isGroupMessage() ? IM_BaseDefine_SessionType.group : IM_BaseDefine_SessionType.single
        msg.sessionType = type
        var msgInfo = [String: Any]()
        if msg.isVoiceMessage() {
            msg.msgContentType = DDMessageContentType.DDMessageTypeVoice
            let tempdata = data.msgData
            let voiceData = tempdata.subdata(in: 4..<tempdata.endIndex)
            let filename =  URL(fileURLWithPath: Encapsulator.defaultFileName())
            do {
                try voiceData.write(to: filename)
                msg.msgContent = Encapsulator.defaultFileName()
            } catch {
                DDLog("语音存储出错")
            }
            
            let voiceLengthData = tempdata.subdata(in: 0..<4)
            
            var ch1 = UInt8()
            voiceLengthData.copyBytes(to: &ch1, from: 0..<1)
            ch1 = ch1 & 0x0ff
            
            var ch2 = UInt8()
            voiceLengthData.copyBytes(to: &ch2, from: 1..<2)
            ch2 = ch2 & 0x0ff
            
            var ch3 = UInt8()
            voiceLengthData.copyBytes(to: &ch3, from: 2..<3)
            ch3 = ch3 & 0x0ff
            
            var ch4 = UInt8()
            voiceLengthData.copyBytes(to: &ch4, from: 3..<4)
            ch4 = ch4 & 0x0ff
            
            if (ch1 | ch2 | ch3 | ch4) < 0 {
                throw MessageError.endOfFile
            }
            
            let voiceLength = UInt32(ch1 << 24) + UInt32(ch2 << 16) + UInt32(ch3 << 8) + UInt32(ch4 << 0)
            msgInfo[VOICE_LENGTH] = voiceLength
            msgInfo[DDVOICE_PLAYED] = 1

        } else {
            let tmpStr = String.init(data: data.msgData, encoding: String.Encoding.utf8)
            msg.msgContent = tmpStr!
        }
        
        if msg.sessionType == IM_BaseDefine_SessionType.single {
            msg.sessionId = MTTUtil.changeOriginalToLocalID(originalID: data.fromUserId, sessionType: type)
        } else {
            msg.sessionId = MTTUtil.changeOriginalToLocalID(originalID: data.toSessionId, sessionType: type)
        }
        
        if MTTMessageEntity.isEmotionMsg(content: msg.msgContent) {
            msg.msgContentType = .DDMessageEmotion
        }
        
        msg.msgID = data.msgId
        msg.toUserID = msg.sessionId
        msg.senderId = MTTUtil.changeOriginalToLocalID(originalID: data.fromUserId, sessionType: IM_BaseDefine_SessionType.single)
        if msg.senderId == RuntimeStatus.sharedInstance.userID {
            msg.sessionId = MTTUtil.changeOriginalToLocalID(originalID: data.toSessionId, sessionType: type)
        }
        msg.msgTime = TimeInterval(data.createTime)
        msg.info = msgInfo
        return msg
    }
    
    func isGroupMessage() -> Bool {
        if self.msgType == IM_BaseDefine_MsgType.groupAudio || self.msgType == IM_BaseDefine_MsgType.groupAudio {
            return true
        }
        return false
    }
    
    func getMessageSessionType() -> IM_BaseDefine_SessionType {
        if isGroupMessage() {
            return IM_BaseDefine_SessionType.single
        } else {
            return IM_BaseDefine_SessionType.group
        }
    }
    
    func isImageMessage() -> Bool {
        if self.msgContentType == DDMessageContentType.DDMessageTypeImage {
            return true
        } else {
            return false
        }
    }
    
    func isVoiceMessage() -> Bool {
        if self.msgType == IM_BaseDefine_MsgType.groupAudio || self.msgType == IM_BaseDefine_MsgType.singleAudio {
            return true
        } else {
            return false
        }
    }
    
    class func isEmotionMsg(content: String) -> Bool{
        return (EmotionsModule.sharedInstance.emotionUnicodeDic?.keys.contains(content))!
    }
    
    func isSendBySelf() -> Bool {
        if self.senderId == RuntimeStatus.sharedInstance.user?.objID {
            return true
        } else {
            return false
        }
    }
    
    enum MessageError: Error {
        case endOfFile
    }
    
    enum DDMessageType: UInt {
        case MESSAGE_TYPE_SINGLE        = 1         //单个人会话消息
        case MESSAGE_TYPE_TEMP_GROUP    = 2         //临时群消息.
    }
    
    enum DDMessageContentType: UInt {
        case DDMessageTypeText      = 0
        case DDMessageTypeImage     = 1
        case DDMessageTypeVoice     = 2
        case DDMessageEmotion       = 3
        case MSG_TYPE_AUDIO         = 100
        case MSG_TYPE_GROUP_AUDIO   = 101
    }
    
    enum DDMessageState: UInt {
        case DDMessageSending       = 0
        case DDMessageSendFailure   = 1
        case DDmessageSendSuccess   = 2
    }
    
    var msgID: UInt32 = 0                                     // MessageID
    var msgType: IM_BaseDefine_MsgType = .singleText        // 消息类型
    var msgTime: TimeInterval = 0.0                         // 消息收发时间
    var sessionId: String = ""                              // 会话id
    var seqNo: UInt = 0
    var senderId: String = ""                               // 发送者的Id，群聊天表示发送者id
    var msgContent: String = ""                             // 消息内容，若为非文本消息则是json
    var toUserID: String = ""                               // 发消息的用户ID
    var info: [String: Any]?                                // 一些附属的属性，包括语音时长
    var msgContentType: DDMessageContentType = .DDMessageTypeText
    var attach: String = ""
    var sessionType: IM_BaseDefine_SessionType = .single
    var state: DDMessageState = .DDMessageSending           // 消息发送状态
}
