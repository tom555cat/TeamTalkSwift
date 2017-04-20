//
//  MTTConstant.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/4.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation
import UIKit

// 屏幕高度
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
// 屏幕宽度
let SCREEN_WIDTH = UIScreen.main.bounds.size.width

let DDINPUT_MIN_HEIGHT: CGFloat = 44.0
let DDINPUT_HEIGHT: CGFloat = 44   // 原来是self.chatInputView.size.height
let SYSTEM_VERSION = Float(UIDevice.current.systemVersion)!
let STATUSBAR_HEIGHT = UIApplication.shared.statusBarFrame.size.height
let NAVBAR_HEIGHT = 44 + ((SYSTEM_VERSION >= Float(7)) ? STATUSBAR_HEIGHT : 0)
let FULL_WIDTH = SCREEN_WIDTH
let FULL_HEIGHT = SCREEN_HEIGHT - ((SYSTEM_VERSION >= Float(7)) ? 0 : STATUSBAR_HEIGHT)
let CONTENT_HEIGHT = FULL_HEIGHT - NAVBAR_HEIGHT


func PhotosMessageDir() -> URL {
    return String.documentPath().appendingPathComponent("PhotosMessageDir")
}

let APP_NAME = "TeamTalk"

let LOCAL_MSG_BEGIN_ID:UInt32 = 1000000

let MAX_CHAT_TEXT_WIDTH = SCREEN_WIDTH - 70.0 * 2

// 图片
let DD_MESSAGE_IMAGE_PREFIX = "&$#@~^@[{:"
let DD_MESSAGE_IMAGE_SUFFIX = ":}]&$~@#@"

// url phone email 正则

let URL_REGULA = "((?:(http|https|Http|Https|rtsp|Rtsp):\\/\\/(?:(?:[a-zA-Z0-9\\$\\-\\_\\.\\+\\!\\*\\'\\(\\)\\,\\;\\?\\&\\=]|(?:\\%[a-fA-F0-9]{2})){1,64}(?:\\:(?:[a-zA-Z0-9\\$\\-\\_\\.\\+\\!\\*\\'\\(\\)\\,\\;\\?\\&\\=]|(?:\\%[a-fA-F0-9]{2})){1,25})?\\@)?)?((?:(?:[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}\\.)+(?:(?:aero|arpa|asia|a[cdefgilmnoqrstuwxz])|(?:biz|b[abdefghijmnorstvwyz])|(?:cat|com|coop|c[acdfghiklmnoruvxyz])|d[ejkmoz]|(?:edu|e[cegrstu])|f[ijkmor]|(?:gov|g[abdefghilmnpqrstuwy])|h[kmnrtu]|(?:info|int|i[delmnoqrst])|(?:jobs|j[emop])|k[eghimnrwyz]|l[abcikrstuvy]|(?:mil|mobi|museum|m[acdghklmnopqrstuvwxyz])|(?:name|net|n[acefgilopruz])|(?:org|om)|(?:pro|p[aefghklmnrstwy])|qa|r[eouw]|s[abcdeghijklmnortuvyz]|(?:tel|travel|t[cdfghjklmnoprtvwz])|u[agkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw]))|(?:(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9])\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[0-9])))(?:\\:\\d{1,5})?)(\\/(?:(?:[a-zA-Z0-9\\;\\/\\?\\:\\@\\&\\=\\#\\~\\-\\.\\+\\!\\*\\'\\(\\)\\,\\_])|(?:\\%[a-fA-F0-9]{2}))*)?(?:\\b|$)"

let PHONE_REGULA = "\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}"

let EMAIL_REGULA = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"

func IPHONE4() -> Bool {
    if UIScreen.main.bounds.size.height == 400 {
        return true
    } else {
        return false
    }
}

// 字体颜色
func TTBG() -> UIColor {
    return UIColor.init(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1)
}

func RGB(_ r: Int, _  g: Int, _ b: Int) ->UIColor {
    return UIColor.init(red: CGFloat(Double(r)/255.0), green: CGFloat(Double(g)/255.0), blue: CGFloat(Double(b)/255.0), alpha: 1)
}

func RGBA(_ r: Int, _ g: Int, _ b: Int, _ a: Float) ->UIColor {
    return UIColor.init(red: CGFloat(Double(r)/255.0), green: CGFloat(Double(g)/255.0), blue: CGFloat(Double(b)/255.0), alpha: CGFloat(a))
}

let DDNotificationTcpLinkConnectComplete = NSNotification.Name("Notification_Tcp_Link_connect_complete")
let DDNotificationTcpLinkConnectFailure = NSNotification.Name("Notification_Tcp_Link_conntect_Failure")
let DDNotificationTcpLinkDisconnect = NSNotification.Name("Notification_Tcp_link_Disconnect")

let DDNotificationUserLoginSuccess = NSNotification.Name("DDNotificationUserLoginSuccess")
let DDNotificationUserLoginFailure = NSNotification.Name("Notification_user_login_failure")
let DDNotificationUserReloginSuccess = NSNotification.Name("DDNotificationUserReloginSuccess")

let DDNotificationUserKickouted = NSNotification.Name("Notification_user_kick_out")
let DDNotificationUserSignChanged = NSNotification.Name("Notification_user_sign_changed")
let DDNotificationPCLoginStatusChanged = NSNotification.Name("Notification_pc_login_status_changed")

let DDNotificationServerHeartBeat = NSNotification.Name("Notification_Server_heart_beat")

let DDNotificationRecentContactsUpdate = NSNotification.Name("DDNotificationRecentContactsUpdate")
let MTTNotificationSessionShieldAndFixed = NSNotification.Name("Notification_SessionShieldAndFixed")

let DDNotificationReceiveMessage = NSNotification.Name("Notification_receive_message")


