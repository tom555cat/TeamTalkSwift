//
//  DDTcpClientManager.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/4.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class DDTcpClientManager: NSObject, StreamDelegate {
    var inStream: InputStream?
    var outStream: OutputStream?
    var receiveLock: NSLock = NSLock()
    var receiveBuffer: NSMutableData? = NSMutableData()
    var sendLock: NSLock = NSLock()
    var sendBuffers: [DDSendBuffer]?
    var lastSendBuffer: DDSendBuffer? = nil
    var noDataSent: Bool = false
    var cDataLen: Int = 0

    
    static let sharedInstance = DDTcpClientManager()
    /*
    class func instance() -> DDTcpClientManager {
        return sharedInstance
    }
    */
    
    func connect(ipAdr: String, port: Int, status: Int) {
        DDLog("mogujie mtalk client :connect ipAdr: \(ipAdr) port:\(port)")
        
        self.cDataLen = 0
        self.receiveBuffer = NSMutableData.init()
        self.sendBuffers = [DDSendBuffer]()
        self.noDataSent = false
        
        self.receiveLock = NSLock()
        self.sendLock = NSLock()
        
        var tempInput: InputStream? = nil
        var tempOutput: OutputStream? = nil
        
        Stream.getStreamsToHost(withName: ipAdr, port: port, inputStream: &tempInput, outputStream: &tempOutput)
        self.inStream = tempInput
        self.outStream = tempOutput
        
        self.inStream?.delegate = self
        self.outStream?.delegate = self
        
        self.inStream?.schedule(in: RunLoop.current, forMode: .defaultRunLoopMode)
        self.outStream?.schedule(in: RunLoop.current, forMode: .defaultRunLoopMode)
        
        self.inStream?.open()
        self.outStream?.open()
    }
    
    func disconnect() {
        DDLog("MTalk Client: disconnect")
        
        self.cDataLen = 0
        self.receiveLock = NSLock()
        self.sendLock = NSLock()
        
        if self.inStream != nil {
            self.inStream?.close()
            self.inStream?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
        }
        self.inStream = nil
        
        if self.outStream != nil {
            self.outStream?.close()
            self.outStream?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
        }
        self.outStream = nil
        
        self.receiveBuffer = nil
        self.sendBuffers = [DDSendBuffer]()
        self.lastSendBuffer = nil
        
        MTTNotification.postNotification(notification: DDNotificationTcpLinkDisconnect, userInfo: [:], object: nil)
    }
    
    func writeToSocket(data: NSMutableData) {
        //objc_sync_enter(sendLock)
        //defer { objc_sync_exit(sendLock) }
        DDLog("发送数据")
        self.sendLock.lock()
        defer { self.sendLock.unlock() }
        if self.noDataSent == true {
            var bytes = [UInt8](repeating: 0, count: data.length)
            data.getBytes(&bytes, length: bytes.count)
            let len = self.outStream?.write(UnsafePointer<UInt8>(bytes), maxLength: data.length)
            self.noDataSent = false
            DDLog("WRITE - Written directly to outStream len: \(len)")
            if len! < data.length {
                DDLog("WRITE - Creating a new buffer for remaining data len: \(data.length - len!)")
                self.lastSendBuffer = DDSendBuffer.dataWithNSData(newdata: data.subdata(with: NSMakeRange(data.length-len!, data.length)) as NSData)
                //self.sendBuffers.add(self.lastSendBuffer!)
                self.sendBuffers?.append(self.lastSendBuffer!)
            }
            return
        }
        
        if (self.lastSendBuffer != nil) {
            let lastSendBufferLength: Int = (self.lastSendBuffer?.length)!
            if lastSendBufferLength < 1024 {
                DDLog("WRITE - Have a buffer with enough space, appending data to it")
                self.lastSendBuffer?.append(data: data)
                return
            }
        }
        
        DDLog("WRITE - Creating a new buffer")
        self.lastSendBuffer = DDSendBuffer.dataWithNSData(newdata: data)
        self.sendBuffers?.append(self.lastSendBuffer!)
    }
    
    //MARK: - Stream Delegate
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.openCompleted:
            p_handleConnectOpenCompletedStream(aStream: aStream)
        case Stream.Event.hasBytesAvailable:
            p_handleEventHasBytesAvailableStream(aStream: aStream)
        case Stream.Event.hasSpaceAvailable:
            p_handleEventHasSpaceAvailableStream(aStream: aStream)
        case Stream.Event.errorOccurred:
            p_handleEventErrorOccurredStream(aStream: aStream)
        case Stream.Event.endEncountered:
            p_handleEventEndEncounteredStream(aStream: aStream)
        default:
            DDLog("Event type: EventNone")
        }
    }
    
    private func p_handleConnectOpenCompletedStream(aStream: Stream) {
        DDLog("handleConnectOpenCompleted")
        if aStream == outStream {
            MTTNotification.postNotification(notification: DDNotificationTcpLinkConnectComplete, userInfo: [:], object: nil)
            DDClientState.sharedInstance.userState = DDUserState.DDUserOnline
        }
    }
    
    private func p_handleEventHasBytesAvailableStream(aStream: Stream) {
        //DDLog("has bytes available")
        if aStream == self.inStream {
            var buf = [UInt8](repeating: 0, count: 1024)
            var len = self.inStream?.read(&buf, maxLength: buf.count)
            
            if len! > 0 {
                self.receiveLock.lock()
                defer {
                    self.receiveLock.unlock()
                }
                self.receiveBuffer?.append(buf, length: len!)
            
                while (self.receiveBuffer?.length)! >= 16 {
                    var range = NSMakeRange(0, 16)
                    let headerData = self.receiveBuffer?.subdata(with: range)
                    let inputData = DDDataInputStream.dataInputStreamWithData(aData: headerData!)
                    
                    do {
                        let pduLen = try Int(inputData.readInt())
                        if pduLen > (self.receiveBuffer?.length)! {
                            DDLog("not enough data received!")
                            break
                        }
                        
                        let tcpHeader = DDTcpProtocolHeader()
                        tcpHeader.version = try inputData.readShort()
                        tcpHeader.flag = try inputData.readShort()
                        tcpHeader.serviceId = try inputData.readShort()
                        tcpHeader.commandId = try inputData.readShort()
                        tcpHeader.reserved = try inputData.readShort()
                        tcpHeader.error = try inputData.readShort()
                        DDLog("receive a packet serviceId=\(tcpHeader.serviceId!), commandId=\(tcpHeader.commandId!)")
                        
                        // pduLen是服务器发送的一个包的长度，receiveBuffer是接收到的数据的长度
                        range = NSMakeRange(16, pduLen - 16)
                        let payloadData = self.receiveBuffer?.subdata(with: range) ///as? NSData
                        let remainLen = (self.receiveBuffer?.length)! - Int(pduLen)
                        
                        range = NSMakeRange(Int(pduLen), remainLen)
                        let remainData = self.receiveBuffer?.subdata(with: range)
                        self.receiveBuffer?.setData(remainData!)  // 将不是当前包的剩余数据重新放置在receiveBuffer的起始位置
                        
                        let dataType = DDMakeServerDataType(serviceID: tcpHeader.serviceId!, commandID: tcpHeader.commandId!, seqNo: tcpHeader.reserved!)
                        DDLog("**************收到服务器端sid: \(tcpHeader.serviceId!) cid\(tcpHeader.commandId!)**************")
                        if (payloadData?.count)! > 0 {
                            DDAPISchedule.sharedInstance.receiveServerData(data: payloadData! as NSData, dataType: dataType)
                        }
                        
                        // 收到包就相当于收到心跳
                        MTTNotification.postNotification(notification: DDNotificationServerHeartBeat, userInfo: [:], object: nil)
                        
                    } catch {
                        DDLog("Error Occured! EOF!")
                    }
                }
            }
 
        }
    }
    
    private func p_handleEventHasSpaceAvailableStream(aStream: Stream) {
        DDLog("has space available")
        self.sendLock.lock()
        defer {
            self.sendLock.unlock()
        }
        
        // 没有数据可以发送
        if self.sendBuffers?.count == 0 {
            DDLog("WRITE - No data to send")
            self.noDataSent = true
            return
        }
        
        // 数据已经发送出去了
        let sendBuffer = self.sendBuffers?[0]
        let sendBufferLength = sendBuffer?.length
        if sendBufferLength! == 0 {
            if sendBuffer! == self.lastSendBuffer! {
                self.lastSendBuffer = nil
            }
            
            self.sendBuffers?.remove(at: 0)
            
            DDLog("WRITE - No data to send")
            
            self.noDataSent = true
            
            return
        }
        
        var len = (sendBufferLength! - (sendBuffer?.sendPos)!) >= 1024 ? 1024 : (sendBufferLength! - (sendBuffer?.sendPos)!)
        if len == 0 {
            if sendBuffer! == self.lastSendBuffer! {
                self.lastSendBuffer = nil
            }
            
            self.sendBuffers?.remove(at: 0)
            
            DDLog("WRITE - No data to send")
            
            self.noDataSent = true
            
            return
        }
        
        var bytes = [UInt8](repeating: 0, count: len)
        sendBuffer?.embeddedData.getBytes(&bytes, range: NSMakeRange((sendBuffer?.sendPos)!, len))
        len = (self.outStream?.write(UnsafePointer<UInt8>(bytes), maxLength: len))!
        DDLog("WRITE - Write directly to outStream len: \(len)")
        sendBuffer?.consumeData(length: len)
        
        if sendBuffer?.length == 0 {
            if sendBuffer! == self.lastSendBuffer! {
                self.lastSendBuffer = nil
            }
            
            self.sendBuffers?.remove(at: 0)
        }
        
        self.noDataSent = false
        return
    }
    
    private func p_handleEventEndEncounteredStream(aStream: Stream) {
        DDLog("handle eventEndEncountered")
        self.cDataLen = 0
    }
    
    private func p_handleEventErrorOccurredStream(aStream: Stream) {
        DDLog("handle eventErrorOccurred")
        self.disconnect()
        DDClientState.sharedInstance.userState = DDUserState.DDUserOffLine
    }
}
