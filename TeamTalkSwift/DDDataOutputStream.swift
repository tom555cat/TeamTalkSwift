//
//  DDDataOutputStream.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/13.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class DDDataOutputStream {
    
    func writeTcpProtocolHeader(sId: UInt16, cId: UInt16, seqNo: UInt16) {
        writeShort(v: UInt16(IM_PDU_VERSION))
        writeShort(v: 0)
        writeShort(v: sId)
        writeShort(v: cId)
        writeShort(v: seqNo)
        writeShort(v: 1)
    }
    
    func writeChar(v: UInt8) {
        var ch = [UInt8]()
        ch.append(v & 0xff)
        self.data.append(ch, length: 1)
        self.length += 1
    }
    
    func writeShort(v: UInt16) {
        var ch = [UInt8]()
        ch.append( UInt8((v & 0x0ff00)>>8) )
        ch.append( UInt8((v & 0x0ff)))
        self.data.append(ch, length: 2)
        self.length += 2
    }
    
    func writeInt(v: UInt32) {
        var ch = [UInt8]()
        ch.append(UInt8((v >> 24) & 0x0ff))
        ch.append(UInt8((v >> 16) & 0x0ff))
        ch.append(UInt8((v >> 8) & 0x0ff))
        ch.append(UInt8((v >> 0) & 0x0ff))
        self.data.append(ch, length: 4)
        self.length += 4
    }
    
    func writeLong(v: UInt64) {
        var ch = [UInt8]()
        ch.append(UInt8((v >> 56) & 0x0ff))
        ch.append(UInt8((v >> 48) & 0x0ff))
        ch.append(UInt8((v >> 40) & 0x0ff))
        ch.append(UInt8((v >> 32) & 0x0ff))
        ch.append(UInt8((v >> 24) & 0x0ff))
        ch.append(UInt8((v >> 16) & 0x0ff))
        ch.append(UInt8((v >> 8) & 0x0ff))
        ch.append(UInt8((v >> 0) & 0x0ff))
        self.data.append(ch, length: 8)
        self.length += 8
    }
    
    func writeUTF(v: String) {
        var d = v.data(using: String.Encoding.utf8)
        let len = UInt32((d?.count)!)
        
        writeInt(v: UInt32(len))
        self.data.append(d!)
        self.length += Int(len)
    }
    
    func writeBytes(v: NSData) {
        let len = v.length
        writeInt(v: UInt32(len))
        self.data.append(v as Data)
        self.length += len
    }
    
    func directWriteBytes(v: NSData) {
        let len = v.length
        self.data.append(v as Data)
        self.length += len
    }
    
    func writeDataCount() {
        var ch = [UInt8]()
        for i in 0..<4 {
            ch.append(UInt8((self.length >> ((3 - i)*8)) & 0x0ff))
        }
        self.data.replaceBytes(in: NSMakeRange(0, 4), withBytes: ch)
    }
    
    func toByteArray() -> NSMutableData {
        return NSMutableData.init(data: self.data as Data)
    }
    
    var data: NSMutableData = NSMutableData()
    var length: Int32 = 0
}
