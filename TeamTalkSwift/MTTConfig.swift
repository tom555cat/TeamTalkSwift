//
//  MTTConfig.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/3.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

let IM_PDU_HEADER_LEN: UInt32 = 16

let IM_PDU_VERSION = 13

let SERVER_ADDR = "http://192.168.54.138:8080/msg_server"

//封装的日志输出功能（T表示不指定日志信息参数类型）
func DDLog<T>(_ message:T, file:String = #file, function:String = #function,
           line:Int = #line) {
    #if DEBUG
        //获取文件名
        let fileName = (file as NSString).lastPathComponent
        //打印日志内容
        print("\(fileName):\(line) \(function) | \(message)")
    #endif
}
