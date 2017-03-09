//
//  MTTUserEntity.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/4.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

let USER_PRE = "user_"

class MTTUserEntity: MTTBaseEntity {
    
    override init() {}
    
    init(userID: String,
         name: String,
         nick: String,
         avatar: String,
         userRole: Int,
         updated: Int32) {
        super.init()
        self.objID = userID
        self.name = name
        self.nick = nick
        self.avatar = avatar
        self.lastUpdateTime = updated
    }
    
    init(pbUser: IM_BaseDefine_UserInfo) {
        super.init()
        self.objID = MTTUserEntity.pbUserIdToLocalID(userID: pbUser.userId)    //String(pbUser.userId)
        self.name = pbUser.userRealName
        self.nick = pbUser.userNickName
        self.avatar = pbUser.avatarURL
        self.department = String(pbUser.departmentId)
        self.departId = ""
        self.telphone = pbUser.userTel
        self.sex = Int32(pbUser.userGender)
        self.email = pbUser.email
        self.pyname = pbUser.userDomain
        self.userStatus = Int(pbUser.status)
        self.signature = pbUser.signInfo
    }
    
    
    //@"serverTime":@(serverTime),
    //@"result":@(loginResult),
    //@"state":@(state),
    //@"nickName":nickName,
    //@"userId":userId,
    //@"title":title,
    //@"position":position,
    //@"isDeleted":@(isDeleted),
    //@"sex":@(sex),
    //@"departId":departId,
    //@"jobNum":@(jobNum),
    //@"telphone":telphone,
    //@"email":email,
    //@"creatTime":@(creatTime),
    //@"updateTime":@(updateTime),
    //@"token":token,
    //@"userType":@(userType)
    class func dicToUserEntity(dic: [String: Any]) -> MTTUserEntity {
        let user = MTTUserEntity()
        user.objID = dic["userId"] as? String
        user.name = dic["name"] as? String
        if let nick = dic["nickName"] as? String {
            user.nick = nick
        } else {
            user.nick = user.name
        }
        
        user.avatar = dic["avatar"] as? String
        user.department = dic["department"] as? String
        user.departId = dic["departId"] as? String
        user.email = dic["email"] as? String
        user.position = dic["position"] as? String
        user.telphone = dic["telphone"] as? String
        user.sex = dic["sex"] as! Int32
        user.lastUpdateTime = (dic["lastUpdateTime"] as? Int32)!
        user.pyname = dic["pyname"] as? String
        user.signature = dic["signature"] as? String
        
        return user
    }

    class func userToDic(user: MTTUserEntity) -> [String: Any] {
        var dic = [String : Any]()
        dic["userId"] = user.objID
        dic["name"] = user.name
        dic["nick"] = user.nick
        dic["avatar"] = user.avatar
        dic["departId"] = user.departId
        dic["email"] = user.email
        dic["department"] = user.department
        dic["position"] = user.position
        dic["telphone"] = user.telphone
        dic["departName"] = user.department
        dic["sex"] = user.sex
        dic["lastUpdateTime"] = user.lastUpdateTime
        return dic
    }
    
    class func localIDTopb(userid: String) -> UInt32 {
        if !userid.hasPrefix(USER_PRE) {
            return 0
        }
        let subString = userid.substring(from: userid.index(userid.startIndex, offsetBy: USER_PRE.characters.count))
        return UInt32(subString)!
    }
    
    class func pbUserIdToLocalID(userID: UInt32) -> String {
        //let str = "\(USER_PRE)\(userID)"
        return String.init(format: "%@%ld", USER_PRE, userID)
    }
    
    func sendEmail() {
        /*
         NSString *stringURL =[NSString stringWithFormat:@"mailto:%@",self.email];
         NSURL *url = [NSURL URLWithString:stringURL];
         [[UIApplication sharedApplication] openURL:url];
        */
    }
    
    func callPhoneNum() {
        /*
         NSString *string = [NSString stringWithFormat:@"tel:%@",self.telphone];
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
        */
    }
    
    func getAvatarUrl() -> String {
        let avatarName = "\(self.avatar)_100x100.jpg"
        return avatarName
    }
    
    func get300AvatarUrl() -> String {
        let avatarName = "\(self.avatar)_310x310.jpg"
        return avatarName
    }
    
    func getAvatarPreImageUrl() -> String {
        let avatarName = "\(self.avatar)_640x999.jpg"
        return avatarName
    }
    
    func updateLastUpdateTimeToDB() {
    }
    
    var name: String?               // 用户名
    var nick: String?               // 用户昵称
    var avatar: String?             // 用户头像
    var department: String?         // 用户部门
    var signature: String?          // 个性签名
    
    var position: String?
    var sex: Int32 = 0
    var departId: String?
    var telphone: String?
    var email: String?
    var pyname: String?
    var userStatus: Int = 0
}
