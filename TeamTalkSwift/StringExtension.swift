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
    
    static func documentPath() -> URL {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectory = paths[0]
        
        return URL.init(fileURLWithPath: documentDirectory)
    }
    
    // 让url所指的内容避免被itune备份
    /*
    static func addSkipBackupAttributeToItemAtURL(url: URL?) -> Bool {
        if url == nil {
            return false
        }
        
        let systemVersion = UIDevice.current.systemVersion
        let version = Float.init(systemVersion)
        if version! < Float(5.0) {
            return true
        } else if version! > Float(5.1) {
            assert(FileManager.default.fileExists(atPath: (url?.absoluteString)!))
            
            do {
                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                //url?.setResourceValues(resourceValues)
                return true
            } catch {
                DDLog("failed")
            }
        }
        
        // 以后还要修改
    }
     */
}
