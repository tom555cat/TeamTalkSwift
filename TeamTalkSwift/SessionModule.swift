//
//  SessionModule.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/29.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

enum SessionAction : Int {
    case ADD = 0
    case REFRESH = 1
    case DELETE = 2
}

protocol SessionModuleDelegate {
    func sessionUpdate(session: MTTSessionEntity, withAction action:SessionAction)
}

class SessionModule {
    init() {
        self.sessions = [String: MTTSessionEntity]()
        NotificationCenter.default.addObserver(self, selector: #selector(sentMessageSuccessfull(notification:)), name: NSNotification.Name("SentMessageSuccessfull"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getMessageReadACK(notification:)), name: NSNotification.Name("MessageReadACK"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(n_receiveMessageNotification(notification:)), name: DDNotificationReceiveMessage, object: nil)
        
        let msgReadNotify = MsgReadNotify()
        msgReadNotify.registerAPIInAPIScheduleReceiveData { (object: Any, error: NSError?) in
            if let dic = object as? Dictionary<String, Any> {
                let fromId = dic["from_id"] as? String
                let msgID = dic["msgId"] as? UInt32
                let type = dic["type"] as? IM_BaseDefine_SessionType
                self.cleanMessageFromNotifi(messageID: msgID!, sessionid: fromId!, type: type!)
            }
        }
    }
    
    @objc func sentMessageSuccessfull(notification: Notification) {
        let session = notification.object as? MTTSessionEntity
        self.addSessionsToSessionModel(sessionArray: [session!])
        if self.delegate != nil {
            self.delegate?.sessionUpdate(session: session!, withAction: .ADD)
        }
        self.updateToDatabase(session: session!)
    }
    
    func updateToDatabase(session: MTTSessionEntity) {
        MTTDatabaseUtil.sharedInstance.updateRecentSession(session: session) { (error: NSError?) in
            DDLog("修改会话出错")
        }
    }
    
    func removeSessionByServer(session: MTTSessionEntity) {
        self.sessions.removeValue(forKey: session.sessionID)
        MTTDatabaseUtil.sharedInstance.removeSession(sessionID: session.sessionID)
        let removeSession = RemoveSessionAPI()
        removeSession.requestWithObject(object: [session.sessionID, session.sessionType]) { (response: Any?, error: Error?) in
            // 什么都不做
        }
    }
    
    func loadLocalSession(closure: @escaping (Bool)->Void) {
        MTTDatabaseUtil.sharedInstance.loadSessionsCompletion { (session: Array<Any>, error: Error?) in
            self.addSessionsToSessionModel(sessionArray: session)
            closure(true)
        }
    }
    
    func addSessionsToSessionModel(sessionArray: Array<Any>) {
        for (_, value) in sessionArray.enumerated() {
            if let session = value as? MTTSessionEntity {
                self.sessions[session.sessionID] = session
            }
        }
    }
    
    func getAllSessions() -> [MTTSessionEntity] {
        let sessions = Array(self.sessions.values)
        for (_, value) in sessions.enumerated() {
            if MTTUtil.checkFixedTop(sessionID: value.sessionID) {
                value.isFixedTop = true
            }
        }
        return Array(self.sessions.values)
    }
    
    private func getMaxTime() -> UInt32 {
        /*
         NSArray *array =[self getAllSessions];
         NSUInteger maxTime = [[array valueForKeyPath:@"@max.timeInterval"] integerValue];
         if (maxTime) {
         return maxTime;
         }
         return 0;
        */
        return 0
    }
    
    func getRecentSession(closure: @escaping (Int)->Void) {
        let getRecentSession = GetRecentSessionAPI()
        let localMaxTime = self.getMaxTime()
        getRecentSession.requestWithObject(object: [localMaxTime]) { (response: Any?, error: Error?) in
            if let array = response as? [MTTSessionEntity] {
                self.addSessionsToSessionModel(sessionArray: array)
                self.getHadUnreadMessageSession(closure: { (obj: UInt) in
                    // 什么都不做
                })
                MTTDatabaseUtil.sharedInstance.updateRecentSessions(sessions: array, completion: { (error: NSError?) in
                    // 什么都不做
                })
                
                closure(0)
            }
        }
    }
    
    private func getHadUnreadMessageSession(closure: @escaping (UInt)->Void) {
        let getUnreadMessage = GetUnreadMessagesAPI()
        getUnreadMessage.requestWithObject(object: [RuntimeStatus.sharedInstance.user?.objID]) { (response: Any?, error: Error?) in
            if let dic = response as? [String: Any] {
                let m_total_cnt = dic["m_total_cnt"] as! UInt32
                let localsessions = dic["sessions"] as! [MTTSessionEntity]
                for localSession in localsessions {
                    if self.getSession(byId: localSession.sessionID) != nil {
                        var session = self.getSession(byId: localSession.sessionID)
                        let lostMsgCount = localSession.lastMsgID - (session?.lastMsgID)!
                        localSession.lastMsg = session?.lastMsg
                        /*    后续还得修改
                         if ([[ChattingMainViewController shareInstance].module.MTTSessionEntity.sessionID isEqualToString:obj.sessionID]) {
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"ChattingSessionUpdate" object:@{@"session":obj,@"count":@(lostMsgCount)}];
                         }
                         */
                        session = localSession
                        self.addToSessionModel(session: localSession)
                    }
                    
                    self.delegate?.sessionUpdate(session: localSession, withAction: SessionAction.ADD)
                }
                
                closure(UInt(m_total_cnt))
            }
        }
    }
    
    func addToSessionModel(session: MTTSessionEntity) {
        self.sessions[session.sessionID] = session
    }
    
    func getAllUnreadMessageCount() -> UInt {
        let allSession = self.getAllSessions()
        var count = 0
        for obj in allSession {
            var unReadMsgCount = obj.unReadMsgCount
            if obj.isGroup() {
                let group = DDGroupModule.sharedInstance.getGroup(byGroupID: obj.sessionID)
                if group != nil {
                    if (group?.isShield)! {
                        if obj.unReadMsgCount > 0 {
                            unReadMsgCount = 0
                        }
                    }
                }
            }
            count += unReadMsgCount
        }
        
        return UInt(count)
    }
    
    @objc func getMessageReadACK(notification: Notification) {
        let message = notification.object as? MTTMessageEntity
        if Array(self.sessions.keys).contains((message?.sessionId)!) {
            let session = self.sessions[(message?.sessionId)!]
            session?.unReadMsgCount = (session?.unReadMsgCount)! - 1
        }
    }
    
    @objc func n_receiveMessageNotification(notification: Notification) {
        let message = notification.object as? MTTMessageEntity
        
        var sessionType: IM_BaseDefine_SessionType = .single
        let session: MTTSessionEntity?
        if (message?.isGroupMessage())! {
            sessionType = .group
        } else {
            sessionType = .single
        }
        
        /*  需要界面完成时再修改
        if Array(self.sessions.keys).contains((message?.sessionId)!) {
            session = self.sessions[(message?.sessionId)!] as? MTTSessionEntity
            session?.lastMsg = (message?.msgContent)!
            session?.lastMsgID = Int((message?.msgID)!)
            session?.timeInterval = UInt((message?.msgTime)!)
            if message?.sessionId {
                
            } else {
            
            }
        }
        */
        
        /*
        self.updateToDatabase(session: session!)
        if self.delegate != nil {
            self.delegate?.sessionUpdate(session: session!, withAction: .ADD)
        }
         */
    }
    
    func getSession(byId sessionID: String) -> MTTSessionEntity? {
        return self.sessions[sessionID]
    }
    
    func cleanMessageFromNotifi(messageID: UInt32, sessionid: String, type: IM_BaseDefine_SessionType) {
        if sessionid != RuntimeStatus.sharedInstance.user?.objID {
            let session = self.getSession(byId: sessionid)
            if session != nil {
                let readCount = messageID - (session?.lastMsgID)!
                if readCount == 0 {
                    session?.unReadMsgCount = 0
                    if self.delegate != nil {
                        self.delegate?.sessionUpdate(session: session!, withAction: .ADD)
                    }
                    self.updateToDatabase(session: session!)
                } else if readCount > 0 {
                    session?.unReadMsgCount = Int(readCount)
                    if self.delegate != nil {
                        self.delegate?.sessionUpdate(session: session!, withAction: .ADD)
                    }
                    self.updateToDatabase(session: session!)
                }
                let readACK = MsgReadACKAPI()
                readACK.requestWithObject(object: [sessionid, messageID, type], completion: {_,_ in 
                    // 什么都不做
                })
            }
        }
    }
    
    //MARK: Property
    static let sharedInstance = SessionModule()
    var delegate: SessionModuleDelegate?
    private var sessions: Dictionary<String, MTTSessionEntity>
}
