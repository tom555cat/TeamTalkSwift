//
//  DDDataInputStream.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/8.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class DDDataInputStream {
    var data: Data?
    var length: Int = 0
    
    init(data: Data) {
        self.data = data
    }
    
    class func dataInputStreamWithData(aData: Data) -> DDDataInputStream {
        let dataInputStream = DDDataInputStream(data: aData)
        return dataInputStream
    }
    
    // 从输入流读取char值
    func readChar() -> UInt8 {
        var v:UInt8 = UInt8()
        let start = self.data?.index((self.data?.startIndex)!, offsetBy: length)
        let end = self.data?.index((self.data?.startIndex)!, offsetBy: length+1)
        let range = Range(start!..<end!)
        self.data?.copyBytes(to: &v, from: range)
        self.length += 1
        return (v & 0xff)
    }
    
    // 从输入流读取short值
    func readShort() throws -> UInt16 {
        let ch1:UInt32 = read()
        let ch2:UInt32 = read()
        if (ch1 | ch2) < 0 {
            throw InputReadError.EOFError
        }
        return UInt16((ch1 << 8) + (ch2 << 0))
    }
    
    // 从输入流读取Int值
    func readInt() throws -> UInt32 {
        let ch1 = self.read()
        let ch2 = self.read()
        let ch3 = self.read()
        let ch4 = self.read()
        if (ch1 | ch2 | ch3 | ch4) < 0 {
            throw InputReadError.EOFError
        }
        return ((ch1 << 24) + (ch2 << 16) + (ch3 << 8) + (ch4 << 0))
    }
    
    // 从输入流读取long值
    /*
    func readLong() -> Int64 {
        var ch = [Int8](repeatElement(0, count: 8))
        data?.getBytes(&ch, range: NSMakeRange(length, 8))
        length += 8
        return ((Int64(ch[0]) << 56) +
            ((Int64)(ch[1] & 255) << 48) +
            ((Int64)(ch[2] & 255) << 40) +
            ((Int64)(ch[3] & 255) << 32) +
            ((Int64)(ch[4] & 255) << 24) +
            ((ch[5] & 255) << 16) +
            ((ch[6] & 255) <<  8) +
            ((ch[7] & 255) <<  0));
    }
    */
    
    // 从输入流读取String字符串
    func readUTF() -> String? {
        do {
            let utfLength = try self.readInt()
            let start = self.data?.index((self.data?.startIndex)!, offsetBy: length)
            let end = self.data?.index((self.data?.startIndex)!, offsetBy: length+Int(utfLength))
            let range = Range(start!..<end!)
            let d = data?.subdata(in: range)
            let str = String(data: d!, encoding:String.Encoding.utf8)
            self.length += Int(utfLength)
            return str!
        } catch {
            print("EOF Occured!")
            return nil
        }
    }
    
    // 取得可读的长度
    func getAvailabledLen() -> UInt {
        return UInt(self.data!.count)
    }
    
    func readDataWithLength(len:Int) -> Data? {
        print("==============>>> length: \(length), len: \(len)")
        
        let start = self.data?.index((self.data?.startIndex)!, offsetBy: length)
        let end = self.data?.index((self.data?.startIndex)!, offsetBy: length+len)
        let range = Range(start!..<end!)
        let d = data?.subdata(in: range)
        self.length += len
        return d
    }
    
    // 读取剩下的数据
    func readLeftData() -> Data? {
        print("==============>>> length \(length), data length is \(data?.count)")
        if (self.data?.count)! > length {
            
            let start = self.data?.index((self.data?.startIndex)!, offsetBy: length)
            let end = self.data?.endIndex
            let range = Range(start!..<end!)
            let d = data?.subdata(in: range)
            self.length  = (self.data?.count)!
            return d
        }
        return nil
    }
    
    private func read() -> UInt32 {
        var v: UInt8 = UInt8()
        let start = self.data?.index((self.data?.startIndex)!, offsetBy: length)
        let end = self.data?.index((self.data?.startIndex)!, offsetBy: length+1)
        let range = Range(start!..<end!)
        self.data?.copyBytes(to: &v, from: range)
        length += 1
        return UInt32(v & 0xff)
    }
    
    enum InputReadError: Error {
        case EOFError
    }
}
