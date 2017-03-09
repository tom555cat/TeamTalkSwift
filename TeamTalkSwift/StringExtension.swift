//
//  StringExtension.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/16.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

extension String {
    func MD5() -> String {
        let ptr = self.cString(using: String.Encoding.utf8)
        let length = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let md5Buffer = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(ptr, length, md5Buffer)
        
        let hash = NSMutableString()
        for i in 0..<CC_MD5_DIGEST_LENGTH {
            hash.appendFormat("%02x", md5Buffer[Int(i)])
        }
        return hash as String
    }
    
    static func userExclusiveDirection() -> String {
        let myName = RuntimeStatus.sharedInstance.user?.objID
        let filemgr = FileManager.default
        let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)
        let directorPath = dirPaths[0].appendingPathComponent(myName!)
        
        if filemgr.fileExists(atPath: directorPath.path) {
            do {
                try filemgr.createDirectory(at: directorPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                DDLog("创建目录出错")
            }
        }
        return directorPath.path
    }
}
