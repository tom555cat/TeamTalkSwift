//
//  DDSendBuffer.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/4.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class DDSendBuffer: NSObject {
    var embeddedData: NSMutableData
    var sendPos: Int
    var length: Int {
        return Int(self.embeddedData.length)
    }
    
    var bytes: UnsafeRawPointer {
        return self.embeddedData.bytes
    }
    
    class func dataWithNSData(newdata: NSData) -> DDSendBuffer
    {
        let obj = DDSendBuffer(data: newdata)
        return obj
    }
    
    init(data: NSData) {
        self.embeddedData = NSMutableData(data: data as Data)
        self.sendPos = 0
    }
    
    func consumeData(length: Int) {
        self.sendPos += length
    }
    
    func setLength(length: Int) {
        self.embeddedData.length = Int(length)
    }
    
    func append(data: NSMutableData) {
        self.embeddedData.append(data as Data)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
