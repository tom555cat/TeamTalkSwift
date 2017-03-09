//
//  MTTDatabaseUtil.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/31.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

let DB_FILE_NAME = "tt.sqlite"
let TABLE_MESSAGE = "message"
let TABLE_ALL_CONTACTS = "allContacts"
let TABLE_DEPARTMENTS = "departments"
let TABLE_GROUPS = "groups"
let TABLE_RECENT_SESSION = "recentSession"

let SQL_CREATE_MESSAGE = String.init(format: "CREATE TABLE IF NOT EXISTS %@ (messageID integer,sessionId text ,fromUserId text,toUserId text,content text, status integer, msgTime real, sessionType integer,messageContentType integer,messageType integer,info text,reserve1 integer,reserve2 text,primary key (messageID,sessionId))", TABLE_MESSAGE)

let SQL_CREATE_DEPARTMENTS = String.init(format: "CREATE TABLE IF NOT EXISTS %@ (ID text UNIQUE,parentID text,title text, description text,leader text, status integer,count integer)", TABLE_DEPARTMENTS)

let SQL_CREATE_ALL_CONTACTS = String.init(format: "CREATE TABLE IF NOT EXISTS %@ (ID text UNIQUE,Name text,Nick text,Avatar text, Department text,DepartID text, Email text,Postion text,Telphone text,Sex integer,updated real,pyname text,signature text)", TABLE_ALL_CONTACTS)

let SQL_CREATE_GROUPS = String.init(format: "CREATE TABLE IF NOT EXISTS %@ (ID text UNIQUE,Avatar text, GroupType integer, Name text,CreatID text,Users Text,LastMessage Text,updated real,isshield integer,version integer)", TABLE_GROUPS)

let SQL_CREATE_RECENT_SESSION = String.init(format: "CREATE TABLE IF NOT EXISTS %@ (ID text UNIQUE,avatar text, type integer, name text,updated real,isshield integer,users Text , unreadCount integer, lasMsg text , lastMsgId integer)", TABLE_RECENT_SESSION)

let SQL_ADD_CONTACTS_SIGNATURE = String.init(format: "ALTER TABLE %@ ADD COLUMN signature TEXT", TABLE_ALL_CONTACTS)

typealias LoadMessageInSessionCompletion = (Array<MTTMessageEntity>, NSError?) -> Void
typealias MessageCountCompletion = (Int) -> Void
typealias DeleteSessionCompletion = (Bool) -> Void
typealias DDGetLastestCommodityMessageCompletion = (MTTMessageEntity) -> Void
typealias DDDBGetLastestMessageCompletion = (MTTMessageEntity?, Error?) -> Void
typealias DDUpdateMessageCompletion = (Bool) -> Void

typealias LoadRecentContactsComplection = (Array<Any>, Error?) -> Void
typealias LoadAllContactsComplection = (Array<Any>, NSError?) -> Void
typealias LoadAllSessionsComplection = (Array<Any>, Error?) -> Void
typealias UpdateRecentContactsComplection = (Error?) -> Void
typealias InsertsRecentContactsComplection = (NSError?) -> Void

class MTTDatabaseUtil {
    static let sharedInstance = MTTDatabaseUtil()
    
    func openCurrentUserDB() {
        if self.database != nil {
            database?.close()
            database = nil
        }
        
        self.dataBaseQueue = FMDatabaseQueue.init(path: self.dbFilePath().absoluteString)
        self.database = FMDatabase.init(path: self.dbFilePath().absoluteString)
        
        
        if (self.database?.open())! == false {
            DDLog("打开数据库失败")
        } else {
            // 更新数据库字段增加signature
            if (self.database?.columnExists("signature", inTableWithName: "allContacts"))! == false {
                // 不存在，需要allContacts增加signature字段
                self.database?.executeUpdate(SQL_ADD_CONTACTS_SIGNATURE, withArgumentsIn: nil)
                // 版本号变0，全部重新获取用户信息
                UserDefaults.standard.set(0, forKey: "alllastupdatetime")
            }
            
            // 检查是否需要 重新获取数据
            let dbVersion = MTTUtil.getDBVersion()
            let lastDbVersion = MTTUtil.getLastDBVersion()
            if dbVersion > lastDbVersion {
                // 删除联系人数据，重新获取
                clearTable(tableName: TABLE_ALL_CONTACTS)
                clearTable(tableName: TABLE_DEPARTMENTS)
                clearTable(tableName: TABLE_GROUPS)
                clearTable(tableName: TABLE_RECENT_SESSION)
                MTTUtil.setLastDBVersion(version: dbVersion)
            }
            
            // 创建
            self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
                if self.database?.tableExists(TABLE_MESSAGE) == false {
                    self.createTable(sql: SQL_CREATE_MESSAGE)
                }
                if self.database?.tableExists(TABLE_DEPARTMENTS) == false {
                    self.createTable(sql: SQL_CREATE_DEPARTMENTS)
                }
                if self.database?.tableExists(TABLE_ALL_CONTACTS) == false {
                    self.createTable(sql: SQL_CREATE_ALL_CONTACTS)
                }
                if self.database?.tableExists(TABLE_GROUPS) == false {
                    self.createTable(sql: SQL_CREATE_GROUPS)
                }
                if self.database?.tableExists(TABLE_RECENT_SESSION) == false {
                    self.createTable(sql: SQL_CREATE_RECENT_SESSION)
                }
            })
        }
        
    }
    
    func dbFilePath() -> URL {
        let directoryPath = String.userExclusiveDirection()
        let fileManager = FileManager.default
        
        // 该用户的db是否存在，若不存在则创建响应的DB目录
        var isDirector: ObjCBool = false
        let isExisting = fileManager.fileExists(atPath: directoryPath, isDirectory: &isDirector)
        if !(isExisting && isDirector.boolValue) {
            do {
                try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
            } catch  {
                DDLog("创建DB目录失败")
            }
        }
        
        let dbPath = URL.init(string: directoryPath)?.appendingPathComponent(String.init(format: "%@_%@", (RuntimeStatus.sharedInstance.user?.objID)!, DB_FILE_NAME))
        return dbPath!
    }
    
    //MARK: ------------ Message ------------
    
    /**
     *  在databaseMessageQueue执行查询操作，分页获取聊天记录
     *
     *  @param sessionID  会话ID
     *  @param pagecount  每页消息数
     *  @param page       页数
     *  @param completion 完成获取
     */
    func loadMessage(sessionID: String, pagecount: Int, index: Int, completion: @escaping LoadMessageInSessionCompletion) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            var array = [MTTMessageEntity]()
            if (self.database?.tableExists(TABLE_MESSAGE))! {
                self.database?.setShouldCacheStatements(true)
                
                let sqlString = "SELECT * FROM message where sessionId=? ORDER BY msgTime DESC limit ?,?"
                let result = self.database?.executeQuery(sqlString, withArgumentsIn: [sessionID, index, pagecount])
                while (result?.next())! {
                    let message = self.messageFromResult(resultSet: result!)
                    array.append(message)
                }
                DispatchQueue.main.async {
                    completion(array, nil)
                }
            }
        })
    }
    
    // 获取某一条消息之后的消息
    func loadMessage(sessionID: String, afterMessage message: MTTMessageEntity, completion: @escaping LoadMessageInSessionCompletion) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            var array = [MTTMessageEntity]()
            if (self.database?.tableExists(TABLE_MESSAGE))! {
                self.database?.setShouldCacheStatements(true)
                let sqlString = String.init(format: "select * from %@ where sessionId = '%@' AND messageID >= ? order by msgTime DESC, messageID DESC", TABLE_MESSAGE, sessionID)
                let result = self.database?.executeQuery(sqlString, withArgumentsIn: [message.msgID])
                while (result?.next())! {
                    let message = self.messageFromResult(resultSet: result!)
                    array.append(message)
                }
                DispatchQueue.main.async {
                    completion(array, nil)
                }
            }
        })
    }
    
    func searchHistory(key: String, completion: @escaping LoadMessageInSessionCompletion) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            var array = [MTTMessageEntity]()
            if (self.database?.tableExists(TABLE_MESSAGE))! {
                self.database?.setShouldCacheStatements(true)
                let sqlString = String.init(format: "select count(*),* from %@ where content like '%%%@%%' and content not like '%%&$#@~^@[{:%%' GROUP BY sessionId", TABLE_MESSAGE, key)
                let result = self.database?.executeQuery(sqlString, withArgumentsIn: nil)
                while (result?.next())! {
                    let message = self.messageFromResult(resultSet: result!)
                    array.append(message)
                }
                DispatchQueue.main.async {
                    completion(array, nil)
                }
            }
        })
    }
    
    func searchHistoryBySessionId(key: String, sessionId: String, completion: @escaping LoadMessageInSessionCompletion) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            var array = [Any]()
            if (self.database?.tableExists(TABLE_MESSAGE))! {
                self.database?.setShouldCacheStatements(true)
                let sqlString = String.init(format: "select * from %@ where content like '%%%@%%' and sessionId = '%@' and content not like '%%&$#@~^@[{:%%'", TABLE_MESSAGE, key, sessionId)
                let result = self.database?.executeQuery(sqlString, withArgumentsIn: nil)
                while (result?.next())! {
                    let message = self.messageFromResult(resultSet: result!)
                    array.append(message)
                }
                DispatchQueue.main.async {
                    completion(array as! Array<MTTMessageEntity>, nil)
                }
            }
        })
    }
    
    /**
     *  获取对应的Session的最新的自己发送的商品气泡
     *  @param sessionID  会话ID
     *  @param completion 完成获取
     */
    func getLatestCommodityTypeImageForSession(sessionID: String, completion: @escaping DDGetLastestCommodityMessageCompletion) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            var array = [Any]()
            if (self.database?.tableExists(TABLE_MESSAGE))! {
                self.database?.setShouldCacheStatements(true)
                let sqlString = String.init(format: "SELECT * from %@ where sessionId=? AND messageType = ? ORDER BY msgTime DESC,rowid DESC limit 0,1", TABLE_MESSAGE)
                let result = self.database?.executeQuery(sqlString, withArgumentsIn: [sessionID, Int(4)])
                var message: MTTMessageEntity?
                while (result?.next())! {
                    message = self.messageFromResult(resultSet: result!)
                    array.append(message!)
                }
                DispatchQueue.main.async {
                    completion(message!)
                }
            }
        })
    }
    
    /**
     *  在databaseMessageQueue执行查询操作，获取DB中
     *  @param sessionID
     *  @param completion 完整获取最新的消息
     */
    func getLastestMessageForSession(sessionID: String, completion: @escaping DDDBGetLastestMessageCompletion) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            if (self.database?.tableExists(TABLE_MESSAGE))! {
                self.database?.setShouldCacheStatements(true)
                let sqlString = String.init(format: "SELECT * FROM %@ where sessionId=? and status = 2 ORDER BY messageId DESC limit 0,1", TABLE_MESSAGE)
                let result = self.database?.executeQuery(sqlString, withArgumentsIn: [sessionID])
                var message: MTTMessageEntity?
                while (result?.next())! {
                    message = self.messageFromResult(resultSet: result!)
                    DispatchQueue.main.async {
                        completion(message!, nil)
                    }
                    break
                }
                if message == nil {
                    completion(message, nil)
                }
            }
        })
    }
    
    /**
     *  在databaseMessageQueue执行查询操作，分页获取聊天记录
     *  @param sessionID
     *  @param completion 完成block
     */
    func getMessagesCount(sessionID: String, completion: @escaping MessageCountCompletion) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            if (self.database?.tableExists(TABLE_MESSAGE))! {
                self.database?.setShouldCacheStatements(true)
                let sqlString = String.init(format: "SELECT COUNT(*) FROM %@ where sessionId=?", TABLE_MESSAGE)
                let result = self.database?.executeQuery(sqlString, withArgumentsIn: [sessionID])
                var count = 0
                while (result?.next())! {
                    count = Int((result?.int(forColumnIndex: 0))!)
                }
                DispatchQueue.main.async {
                    completion(count)
                }
            }
        })
        
    }
    
    /**
     *  批量插入message, 需要用户必须在线，避免插入里显示阅读的消息
     *
     *  @param message message集合
     *  @param success 插入成功
     *  @param failure 插入失败
     */
    func insertMessage(messageArray: [MTTMessageEntity], success: @escaping ()->Void, failure: @escaping (String)->Void) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            self.database?.beginTransaction()
            var isRollBack: Bool = false
            for message in messageArray {
                let sql = String.init(format: "INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)", TABLE_MESSAGE)
                do {
                    let infoJsonData = try JSONSerialization.data(withJSONObject: message.info, options: .prettyPrinted)
                    let json = String.init(data: infoJsonData, encoding: String.Encoding.utf8)
                    let result = self.database?.executeUpdate(sql, withArgumentsIn: [message.msgID, message.sessionId, message.senderId, message.toUserID, message.msgContent, message.state, message.msgTime, Int(1), message.msgContentType.rawValue, message.msgType.rawValue, json!, Int(0), ""])
                    if !result! {
                        isRollBack = true
                    }
                } catch {
                    DDLog(error.localizedDescription)
                    self.database?.rollback()
                    failure("插入数据失败")
                }
                
            }
            
            defer {
                if isRollBack {
                    self.database?.rollback()
                    DDLog("数据库插入失败")
                    failure("插入数据失败")
                } else {
                    self.database?.commit()
                    success()
                }
            }
        })
    }
    
    /**
     *  删除会话的所有消息
     *
     *  @param sessionID 会话
     *  @param completion 完成删除
     */
    func deleteMessage(sessionID: String, completion: @escaping DeleteSessionCompletion) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            let sql = "DELETE FROM message WHERE sessionId = ?"
            let result = self.database?.executeUpdate(sql, withArgumentsIn: [sessionID])
            DispatchQueue.main.async {
                completion(result!)
            }
        })
    }
    
    
    
    /**
     *  更新数据库中的某条消息
     *
     *  @param message  更新后的消息
     *  @param completion  完成更新
     */
    func updateMessage(message: MTTMessageEntity, completion: @escaping DDUpdateMessageCompletion) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            let sql = String.init(format: "UPDATE %@ set sessionId = ? , fromUserId = ? , toUserId = ? , content = ? , status = ? , msgTime = ? , sessionType = ? , messageType = ? ,messageContentType = ? , info = ? where messageID = ?", TABLE_MESSAGE)
            do {
                let infoJsonData = try JSONSerialization.data(withJSONObject: message.info, options: .prettyPrinted)
                let json = String.init(data: infoJsonData, encoding: String.Encoding.utf8)
                let result = self.database?.executeUpdate(sql, withArgumentsIn: [message.sessionId, message.senderId, message.toUserID, message.msgContent, message.state, message.msgTime, message.sessionType.rawValue, message.msgType.rawValue, message.msgContentType.rawValue, json!, message.msgID])
                DispatchQueue.main.async {
                    completion(result!)
                }
            } catch {
                DDLog("修改消息失败")
                DDLog(error.localizedDescription)
            }
        })
    }
    
    
    //MARK: Message Private function
    private func messageFromResult(resultSet: FMResultSet) -> MTTMessageEntity {
        let sessionID = resultSet.string(forColumn: "sessionId")
        let fromUserId = resultSet.string(forColumn: "fromUserId")
        let toUserId = resultSet.string(forColumn: "toUserId")
        let content = resultSet.string(forColumn: "content")
        let msgTime = resultSet.double(forColumn: "msgTime")
        let messageType :IM_BaseDefine_MsgType = IM_BaseDefine_MsgType(rawValue: Int(resultSet.int(forColumn: "messageType")))!
        let messageContentType = resultSet.int(forColumn: "messageContentType")
        //let messageID = resultSet.int(forColumn: "messageID")
        let messageID = resultSet.unsignedLongLongInt(forColumn: "messageID")
        let messageState = resultSet.int(forColumn: "status")
        
        let messageEntity = MTTMessageEntity.init(ID: UInt32(messageID), msgType: IM_BaseDefine_MsgType(rawValue: messageType.rawValue)!, msgTime: msgTime, sessionID: sessionID!, senderID: fromUserId!, msgContent: content!, toUserID: toUserId!)
        messageEntity.state = MTTMessageEntity.DDMessageState(rawValue: UInt(messageState))!
        messageEntity.msgContentType = MTTMessageEntity.DDMessageContentType(rawValue: UInt(messageContentType))!
        let infoString = resultSet.string(forColumn: "info")
        if (infoString != nil) {
            let infoData: Data = (infoString?.data(using: String.Encoding.utf8))!
            do {
                let info = try JSONSerialization.jsonObject(with: infoData, options: JSONSerialization.ReadingOptions.mutableContainers)
                if let info = info as? [String: Any] {
                    messageEntity.info = info
                }
            } catch {
                DDLog("JSON转换出错")
            }
        }
        
        return messageEntity
    }
    
    //MARK: ------------ Users ------------
    /**
     *  加载本地数据库的最近联系人列表
     *
     *  @param completion 完成加载
     */
    func loadContacts(completion: LoadRecentContactsComplection) {}
    
    /**
     *  更新本地数据库的最近联系人信息
     *
     *  @param completion 完成更新本地数据库
     */
    func updateContacts(users: Array<Any>, completion: UpdateRecentContactsComplection) {}
    
    /**
     *  插入本地数据库的最近联系人信息
     *
     *  @param users      最近联系人数组
     *  @param completion 完成插入
     */
    func insertUsers(users: Array<Any>, completion: InsertsRecentContactsComplection) {}
    
    /**
     *  插入组织架构信息
     *
     *  @param departments 组织架构数组
     *  @param completion  完成插入
     */
    func insertDepartments(departments: Array<Any>, completion: @escaping InsertsRecentContactsComplection) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            self.database?.beginTransaction()
            var isRollBack = false
            for (index, value) in departments.enumerated() {
                if let department = value as? MTTDepartment {
                    let sql = String.init(format: "INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?)", TABLE_DEPARTMENTS)
                    let result = self.database?.executeUpdate(sql, withArgumentsIn: [department.ID, department.parentID, department.title, department.description, department.leader, department.status, department.count])
                    if !result! {
                        isRollBack = true
                    }
                }
            }
            
            defer {
                if isRollBack {
                    self.database?.rollback()
                    DDLog("inert to database failure content")
                    let error = NSError.init(domain: "批量插入部门信息失败", code: 0, userInfo: nil)
                    completion(error)
                } else {
                    self.database?.commit()
                    completion(nil)
                }
            }
        })
    }
    
    func getDepartmentFrom(departmentID: String, completion: @escaping (MTTDepartment)->Void) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            if (self.database?.tableExists(TABLE_DEPARTMENTS))! {
                self.database?.setShouldCacheStatements(true)
                let sqlString = String.init(format: "SELECT * FROM %@ where ID=?", TABLE_DEPARTMENTS)
                let result = self.database?.executeQuery(sqlString, withArgumentsIn: [departmentID])
                var department: MTTDepartment?
                while (result?.next())! {
                    department = self.departmentFromResult(resultSet: result!)
                }
                DispatchQueue.main.async {
                    completion(department!)
                }
            }
        })
    }
    
    func insertAllUSers(users: Array<Any>, completion: @escaping InsertsRecentContactsComplection) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            self.database?.beginTransaction()
            var isRollBack = false
            for (_, value) in users.enumerated() {
                let user = value as? MTTUserEntity
                if user?.userStatus == 3 {
                    user?.telphone = ""
                    user?.email = ""
                    user?.name = ""
                }
                let sql = String.init(format: "INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)", TABLE_ALL_CONTACTS)
                let result = self.database?.executeUpdate(sql, withArgumentsIn: [user?.objID, user?.name, user?.nick, user?.avatar, user?.department, user?.departId, user?.email, user?.position, user?.telphone, user?.sex, user?.lastUpdateTime, user?.pyname, user?.signature])
                if !result! {
                    isRollBack = true
                }
            }
            
            defer {
                if isRollBack {
                    self.database?.rollback()
                    DDLog("insert to database failure content")
                    let error = NSError.init(domain: "批量插入全部用户信息失败", code: 0, userInfo: nil)
                    completion(error)
                } else {
                    self.database?.commit()
                    completion(nil)
                }
            }
        })
    }
    
    func getAllUsers(completion: @escaping LoadAllContactsComplection) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            if (self.database?.tableExists(TABLE_ALL_CONTACTS))! {
                self.database?.setShouldCacheStatements(true)
                var array = [Any]()
                let sqlString = String.init(format: "SELECT * FROM %@ ", [TABLE_ALL_CONTACTS])
                let result = self.database?.executeQuery(sqlString, withArgumentsIn: nil)
                while (result?.next())! {
                    let user = self.userFromResult(resultSet: result!)
                    if user.userStatus != 3 {
                        array.append(user)
                    }
                }
                DispatchQueue.main.async {
                    completion(array, nil)
                }
            }
        })
    }
    
    func getUserFrom(userID: String, completion: @escaping (MTTUserEntity)->Void) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            if (self.database?.tableExists(TABLE_ALL_CONTACTS))! {
                self.database?.setShouldCacheStatements(true)
                
                let sqlString = String.init(format: "SELECT * FROM %@ where ID= ?", [TABLE_ALL_CONTACTS])
                let result = self.database?.executeQuery(sqlString, withArgumentsIn: [userID])
                var user:MTTUserEntity?
                while (result?.next())! {
                    user = self.userFromResult(resultSet: result!)
                }
                DispatchQueue.main.async {
                    completion(user!)
                }
            }
        })
    }
    
    func updateRecentGroup(group: MTTGroupEntity, completion: @escaping InsertsRecentContactsComplection) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            self.database?.beginTransaction()
            var isRollBack = false
            let sql = String.init(format: "INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?,?,?)", TABLE_GROUPS)
            var users: String = ""
            if (group.groupUserIds?.count)! > 0 {
                users = (group.groupUserIds?.joined(separator: "-"))!
            }
            let result = self.database?.executeUpdate(sql, withArgumentsIn: [group.objID, group.avatar, group.groupType, group.name, group.groupCreatorId, users, group.lastMsg, group.lastUpdateTime, group.isShield, group.objectVersion])
            if !result! {
                isRollBack = true
            }
            
            defer {
                if isRollBack {
                    self.database?.rollback()
                    DDLog("insert into database failure content")
                    let error = NSError.init(domain: "插入最近群失败", code: 0, userInfo: nil)
                    completion(error)
                } else {
                    self.database?.commit()
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        })
    }
    
    func updateRecentSessions(sessions: Array<Any>, completion: @escaping InsertsRecentContactsComplection) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            self.database?.beginTransaction()
            var isRollBack = false
            for (_, value) in sessions.enumerated() {
                if let session = value as? MTTSessionEntity {
                    let sql = String.init(format: "INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?,?,?)", TABLE_RECENT_SESSION)
                    var users: String = ""
                    if  session.sessionUsers != nil && (session.sessionUsers?.count)! > 0 {
                        users = (session.sessionUsers?.joined(separator: "-"))!
                    }
                    let result = self.database?.executeUpdate(sql, withArgumentsIn: [session.sessionID, session.avatar, session.sessionType.rawValue, session.name, session.timeInterval, session.isShield, users, session.unReadMsgCount, session.lastMsg, session.lastMsgID])
                    if !result! {
                        isRollBack = true
                    }
                }
            }
            
            defer {
                if isRollBack {
                    self.database?.rollback()
                    DDLog("insert into database failure content")
                    let error = NSError.init(domain: "插入最近Session失败", code: 0, userInfo: nil)
                    //completion(error)
                    DispatchQueue.main.async {
                        completion(error)
                    }
                } else {
                    self.database?.commit()
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        })
    }
    
    func updateRecentSession(session: MTTSessionEntity, completion: @escaping InsertsRecentContactsComplection) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            self.database?.beginTransaction()
            var isRollBack = false
            let sql = String.init(format: "INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?,?,?)", TABLE_RECENT_SESSION)
            var users: String = ""
            if (session.sessionUsers?.count)! > 0 {
                users = (session.sessionUsers?.joined(separator: "-"))!
            }
            let result = self.database?.executeUpdate(sql, withArgumentsIn: [session.sessionID, session.avatar, session.sessionType.rawValue, session.name, session.timeInterval, session.isShield, users, session.unReadMsgCount, session.lastMsg, session.lastMsgID])
            if !result! {
                isRollBack = true
            }
            
            defer {
                if isRollBack {
                    self.database?.rollback()
                    DDLog("insert into database failure content")
                    let error = NSError.init(domain: "插入最近Session失败", code: 0, userInfo: nil)
                    completion(error)
                } else {
                    self.database?.commit()
                    completion(nil)
                }
            }
        })
    }
    
    func loadGroupsCompletion(completion: @escaping LoadRecentContactsComplection) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            var array = [Any]()
            if (self.database?.tableExists(TABLE_GROUPS))! {
                self.database?.setShouldCacheStatements(true)
                
                let sqlString = String.init(format: "SELECT * FROM %@", TABLE_GROUPS)
                let result = self.database?.executeQuery(sqlString, withArgumentsIn: nil)
                while (result?.next())! {
                    let group = self.groupFromResult(resultSet: result!)
                    array.append(group)
                }
                DispatchQueue.main.async {
                    completion(array, nil)
                }
            }
        })
    }
    
    func loadSessionsCompletion(completion: @escaping LoadAllSessionsComplection) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            var array = [Any]()
            if (self.database?.tableExists(TABLE_RECENT_SESSION))! {
                self.database?.setShouldCacheStatements(true)
                
                let sqlString = String.init(format: "SELECT * FROM %@ order BY updated DESC", TABLE_RECENT_SESSION)
                let result = self.database?.executeQuery(sqlString, withArgumentsIn: nil)
                while (result?.next())! {
                    let session = self.sessionFromResult(resultSet: result!)
                    array.append(session)
                }
                DispatchQueue.main.async {
                    completion(array, nil)
                }
            }
        })
    }
    
    func removeSession(sessionID: String) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            let sql = "DELETE FROM recentSession WHERE ID = ?"
            let result = self.database?.executeUpdate(sql, withArgumentsIn: [sessionID])
            if result! {
                let sql = "DELETE FROM message WHERE sessionId = ?"
                let result = self.database?.executeUpdate(sql, withArgumentsIn: [sessionID])
            }
        })
    }
    
    func deleteMessage(message: MTTMessageEntity, completion: DeleteSessionCompletion) {
    }
    
    func loadGroupByIDCompletion(groupID: String, completion: @escaping LoadRecentContactsComplection) {
        self.dataBaseQueue?.inDatabase({ (db: FMDatabase?) in
            var array = [Any]()
            if (self.database?.tableExists(TABLE_GROUPS))! {
                self.database?.setShouldCacheStatements(true)
                let sqlString = String.init(format: "SELECT * FROM %@ where ID= ? ", TABLE_GROUPS)
                let result = self.database?.executeQuery(sqlString, withArgumentsIn: [groupID])
                while (result?.next())! {
                    let group = self.groupFromResult(resultSet: result!)
                    array.append(group)
                }
                DispatchQueue.main.async {
                    completion(array, nil)
                }
            }
        })
    }
    
    //MARK: User Private function
    private func departmentFromResult(resultSet: FMResultSet) -> MTTDepartment {
        let dic = ["departID": resultSet.string(forColumn: "ID"), "title": resultSet.string(forColumn: "title"), "description": resultSet.string(forColumn: "description"), "leader": resultSet.string(forColumn: "leader"), "parentID": resultSet.string(forColumn: "parentID"), "status": resultSet.int(forColumn: "status"), "count": resultSet.int(forColumn: "count")] as [String : Any]
        let department = MTTDepartment.departmentFrom(dic: dic)
        return department
    }
    
    private func userFromResult(resultSet: FMResultSet) -> MTTUserEntity {
        var dic = [String: Any]()
        dic["name"] = resultSet.string(forColumn: "Name")
        dic["nickName"] = resultSet.string(forColumn: "Nick")
        dic["userId"] = resultSet.string(forColumn: "ID")
        dic["department"] = resultSet.string(forColumn: "Department")
        dic["position"] = resultSet.string(forColumn: "Position")
        dic["sex"] = resultSet.int(forColumn: "Sex")
        dic["departId"] = resultSet.string(forColumn: "DepartID")
        dic["telphone"] = resultSet.string(forColumn: "Telphone")
        dic["avatar"] = resultSet.string(forColumn: "Avatar")
        dic["email"] = resultSet.string(forColumn: "Email")
        dic["lastUpdateTime"] = resultSet.int(forColumn: "updated")
        dic["pyname"] = resultSet.string(forColumn: "pyname")
        dic["signature"] = resultSet.string(forColumn: "signature")
        let user = MTTUserEntity.dicToUserEntity(dic: dic)
        
        return user
    }
    
    private func groupFromResult(resultSet: FMResultSet) -> MTTGroupEntity {
        var dic = [String: Any]()
        dic["name"] = resultSet.string(forColumn: "Name")
        dic["groupId"] = resultSet.string(forColumn: "ID")
        dic["avatar"] = resultSet.string(forColumn: "Avatar")
        dic["groupType"] = resultSet.int(forColumn: "GroupType")
        dic["lastUpdateTime"] = resultSet.long(forColumn: "updated")
        dic["creatID"] = resultSet.string(forColumn: "CreatID")
        dic["Users"] = resultSet.string(forColumn: "Users")
        dic["lastMessage"] = resultSet.string(forColumn: "LastMessage")
        dic["isshield"] = resultSet.int(forColumn: "isshield")
        dic["version"] = resultSet.int(forColumn: "version")
        let group = MTTGroupEntity.dicToMTTGroupEntity(dic: dic)
        
        return group
    }
    
    private func sessionFromResult(resultSet: FMResultSet) -> MTTSessionEntity {
        //let sessionTypeRawValue: Int = Int(resultSet.longLongInt(forColumn: "type"))
        let sessionRawValue = resultSet.int(forColumn: "type")
        let sessionType = IM_BaseDefine_SessionType.init(rawValue: Int(resultSet.int(forColumn: "type")))
        let session = MTTSessionEntity.init(sessionID: resultSet.string(forColumn: "ID"), name: resultSet.string(forColumn: "name"), type: sessionType!)
        session.avatar = resultSet.string(forColumn: "avatar")
        session.timeInterval = UInt(resultSet.long(forColumn: "updated"))
        session.lastMsg = resultSet.string(forColumn: "lasMsg")
        //session.lastMsgID = UInt32(UInt(resultSet.long(forColumn: "lastMsgId")))
        session.lastMsgID = UInt32(resultSet.unsignedLongLongInt(forColumn: "lastMsgId"))
        session.unReadMsgCount = resultSet.long(forColumn: "unreadCount")
        return session
    }
    
    //MARK: Private function
    private func clearTable(tableName: String) -> Bool{
        var result = false
        self.database?.setShouldCacheStatements(true)
        let tempSql = String.init(format: "DELETE FROM %@", tableName)
        result = (self.database?.executeUpdate(tempSql, withArgumentsIn: nil))!
        
        return result
    }
    
    private func createTable(sql: String) -> Bool {
        var result = false
        self.database?.setShouldCacheStatements(true)
        result = (self.database?.executeUpdate(sql, withArgumentsIn: nil))!
        
        return result
    }
    
    private var database: FMDatabase?
    private var dataBaseQueue: FMDatabaseQueue?
    private var databasePath: String?
}
