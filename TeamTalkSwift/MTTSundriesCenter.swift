//
//  MTTSundriesCenter.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2016/12/31.
//  Copyright © 2016年 Hello World Corporation. All rights reserved.
//

import Foundation
import Dispatch

typealias MTTTask = () -> Void

class MTTSundriesCenter
{
    let serialQueue = DispatchQueue(label: "com.mogujie.SundriesSerial")    // 默认创建串行队列
    
    let parallelQueue = DispatchQueue(label: "com.mogujie.SundriesParallel", attributes: .concurrent)
    
    // 单例
    static let sharedInstance = MTTSundriesCenter()
    
    func pushTaskToSerialQueue(task: @escaping MTTTask) -> Void
    {
        serialQueue.async(execute: task)
    }
    
    func pushTaskToParallelQueue(task: @escaping MTTTask) -> Void
    {
        parallelQueue.async(execute: task)
    }
    
    func pushTaskToSynchronizationSerialQueue(task: MTTTask) -> Void
    {
        serialQueue.sync(execute: task)
    }
}
