//
//  DDTcpProtocolHeader.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/9.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

// SID
enum SID: UInt16 {
    case SID_LOGIN                                   = 0x0001
    case SID_BUDDY_LIST                              = 0x0002
    case SID_MSG                                     = 0x0003
    case SID_GROUP                                   = 0x0004
    case SID_SWITCH_SERVICE                          = 0x0006
    case SID_OTHER                                   = 0x0007
}

// SID_LOGIN
enum SID_LOGIN: UInt16 {
    case IM_LOGIN_REQ                                = 0x0103
    case IM_LOGIN_RES                                = 0x0104
    case IM_LOGOUT_REQ                               = 0x0105
    case IM_LOGOUT_RES                               = 0x0106
    case IM_KICK_USER                                = 0x0107
    case IM_DEVICE_TOKEN_REQ                         = 0x0108
    case IM_DEVICE_TOKEN_RES                         = 0x0109
    case IM_KICK_PC_CLIENT_REQ                       = 0x010a
    case IM_KICK_PC_CLIENT_RES                       = 0x010b
    case IM_PUSH_SHIELD_REQ                          = 0x010c
    case IM_PUSH_SHIELD_RES                          = 0x010d
    case IM_QUERY_PUSH_SHIELD_REQ                    = 0x010e
    case IM_QUERY_PUSH_SHIELD_RES                    = 0x010f
}

// SID_BUDDY_LIST
enum SID_BUDDY_LIST: UInt16 {
    case IM_RECENT_CCONTACT_SESSION_REQ              = 0x0201
    case IM_RECENT_CCONTACT_SESSION_RES              = 0x0202
    case IM_USERS_INFO_REQ                           = 0x0204
    case IM_USERS_INFO_RES                           = 0x0205
    case IM_REMOVE_SESSION_REQ                       = 0x0206
    case IM_REMOVE_SESSION_RES                       = 0x0207
    case IM_ALL_USER_REQ                             = 0x0208
    case IM_ALL_USER_RES                             = 0x0209
    case IM_USERS_STAT_REQ                           = 0x020a
    case IM_USERS_STAT_RSP                           = 0x020b
    case IM_PC_LOGIN_STATUS_NOTIFY                   = 0x020e
    case IM_CHANGE_SIGN_INFO_REQ                     = 0x0213
    case IM_CHANGE_SIGN_INFO_RES                     = 0x0214
    case IM_SIGN_INFO_CHANGED_NOTIFY                 = 0x0215
}

// SID_MSG
enum SID_MSG: UInt16 {
    case IM_MSG_DATA                                 = 0x0301
    case IM_MSG_DATA_ACK                             = 0x0302
    case IM_MSG_DATA_READ_ACK                        = 0x0303
    case IM_MSG_DATA_READ_NOTIFY                     = 0x0304
    case IM_UNREAD_MSG_CNT_REQ                       = 0x0307
    case IM_UNREAD_MSG_CNT_RSP                       = 0x0308
    case IM_GET_MSG_LIST_REQ                         = 0x0309
    case IM_GET_MSG_LIST_RSP                         = 0x030a
    case IM_GET_LASTEST_MSGID_REQ                    = 0x030b
    case IM_GET_LASTEST_MSGID_RES                    = 0x030c
    case IM_GET_MSG_BY_ID_REQ                        = 0x030d
    case IM_GET_MSG_BY_ID_RES                        = 0x030e
}

// SID_GROUP
enum SID_GROUP: UInt16 {
    case IM_NORMAL_GROUP_LIST_REQ                    = 0x0401
    case IM_NORMAL_GROUP_LIST_RES                    = 0x0402
    case IM_GROUP_INFO_LIST_REQ                      = 0x0403
    case IM_GROUP_INFO_LIST_RES                      = 0x0404
    case IM_GROUP_CREATE_REQ                         = 0x0405
    case IM_GROUP_CREATE_RES                         = 0x0406
    case IM_GROUP_CHANGE_MEMBER_REQ                  = 0x0407
    case IM_GROUP_CHANGE_MEMBER_RES                  = 0x0408
    case IM_GROU_SHIELD_REQ                          = 0x0409
    case IM_GROU_SHIELD_RES                          = 0x040a
}

// SID_SWITCH_SERVICE
enum SID_SWITCH_SERVICE: UInt16 {
    case IM_P2P_CMD_MSG                              = 0x0601
}

// SID_OTHER
enum SID_OTHER: UInt16 {
    case IM_HEART_BEAT                               = 0x0701
}

class DDTcpProtocolHeader {
    var version: UInt16?
    var flag: UInt16?
    var serviceId: UInt16?
    var commandId: UInt16?
    var reserved: UInt16?
    var error: UInt16?
}
