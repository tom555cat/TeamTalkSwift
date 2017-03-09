//
//  UnAckMessageManager.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/3/2.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

let MESSAGE_TIMEOUT_SEC: Double = 5

class MessageAndTime {
    
    var msg: MTTMessageEntity?
    
    var nowDate: TimeInterval = 0
    
}

class UnAckMessageManager {
    
    static let sharedInstance = UnAckMessageManager()
    private var msgDic: [UInt32: MessageAndTime]?
    private var ack_timer: Timer?
    
    init() {
        self.msgDic = [UInt32: MessageAndTime]()
        self.ack_timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(checkMessageTimeout), userInfo: nil, repeats: true)
    }
    
    func removeMessageFromUnAckQueue(message: MTTMessageEntity) {
        if (self.msgDic?.keys.contains(message.msgID))! {
            self.msgDic?.removeValue(forKey: message.msgID)
        }
    }
    
    func addMessageToUnAckQueue(message: MTTMessageEntity) {
        let msgAndTime = MessageAndTime()
        msgAndTime.msg = message
        msgAndTime.nowDate = NSTimeIntervalSince1970
        if self.msgDic != nil {
            self.msgDic?[message.msgID] = msgAndTime
        }
    }
    
    func isInUnAckQueue(message: MTTMessageEntity) -> Bool {
        if (self.msgDic?.keys.contains(message.msgID))! {
            return true
        } else {
            return false
        }
    }
    
    @objc private func checkMessageTimeout() {
        for (_, value) in self.msgDic! {
            let timeNow = Date.timeIntervalBetween1970AndReferenceDate
            let msgTimeOut = value.nowDate + MESSAGE_TIMEOUT_SEC
            if timeNow >= msgTimeOut {
                DDLog("timeout time is \(msgTimeOut), msg id is \(value.msg?.msgID)")
                value.msg?.state = .DDMessageSendFailure
                MTTDatabaseUtil.sharedInstance.updateMessage(message: value.msg!, completion: { (result: Bool) in
                    // 什么都不做
                })
                self.removeMessageFromUnAckQueue(message: value.msg!)
            }
        }
    }
}

