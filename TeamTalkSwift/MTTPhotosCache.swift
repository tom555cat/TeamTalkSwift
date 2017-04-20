//
//  MTTPhotosCache.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/3/9.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation
import UIKit

typealias cacheblock = (Bool) -> Void

class MTTPhotoEntity {
    var localPath: String?
    var resultUrl: String?
    var imageRef: CGImage?
    var image: UIImage?
}

class MTTPhotoCache {
    
    static let sharedInstance = MTTPhotoCache()
    private var fileManager: FileManager?
    private var ioQueue: DispatchQueue?
    private var memCache: NSCache<AnyObject, AnyObject>?
    
    init() {
        self.ioQueue = DispatchQueue.init(label: "com.mogujie.DDPhotosCache")
        self.memCache = NSCache.init()
        
        self.ioQueue?.sync {
            self.fileManager = FileManager.init()
        }
    }
    
    class func calculatePhotoSize(withCompletionBlock completion: ((UInt, UInt) -> Void)?) {
        let diskCacheURL = PhotosMessageDir()
        MTTSundriesCenter.sharedInstance.pushTaskToSerialQueue {
            var fileCount: UInt = 0
            var totalSize: UInt = 0
            // ？？？？？ 使用新创建的fileManager和默认的fileManager有什么区别?
            let fileEnumerator = FileManager.default.enumerator(at: diskCacheURL, includingPropertiesForKeys: [URLResourceKey.fileSizeKey], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles, errorHandler: nil)
            
            while let fileURL = fileEnumerator?.nextObject() as? URL {
                let keySet: Set = [URLResourceKey.fileSizeKey]
                do {
                    let resourceValues = try fileURL.resourceValues(forKeys: keySet)
                    totalSize += resourceValues.allValues[URLResourceKey.fileSizeKey] as! UInt
                    fileCount += 1
                } catch {
                    DDLog("获取URL缓存出错")
                }
            }
            
            if completion != nil {
                DispatchQueue.main.async {
                    completion!(fileCount, totalSize)
                }
            }
            
        }
    }
    
    func storePhoto(photos: Data, forKey key: String, toDisk: Bool) {
        self.memCache?.setObject(photos as AnyObject, forKey: key as AnyObject)
        
        if toDisk {
            self.ioQueue?.async {
                do {
                    if !FileManager.default.fileExists(atPath: PhotosMessageDir().absoluteString) {
                        try FileManager.default.createDirectory(at: PhotosMessageDir(), withIntermediateDirectories: true, attributes: nil)
                        DDLog("directory is: \(PhotosMessageDir())")
                    }
                    
                    FileManager.default.createFile(atPath: self.defaultCachePath(forKey: key), contents: photos, attributes: nil)
                    
                } catch {
                    DDLog("创建目录失败!")
                }
            }
        }
    }
    
    func photoFromDiskCache(forKey key: String) -> Data? {
        let photoData = self.photoFromMemoryCache(forKey: key)
        if photoData != nil {
            return photoData
        }
        
        // 检查是否在磁盘上
        let diskPhotoData = self.diskPhoto(forKey: key)
        if diskPhotoData != nil {
            self.memCache?.setObject(diskPhotoData as AnyObject, forKey: key as AnyObject)
        }
        
        /*
        let diskPhotoData = self.photoFromMemoryCache(forKey: key)
        if diskPhotoData != nil {
            self.memCache?.setObject(diskPhotoData! as AnyObject, forKey: key as AnyObject)
        }
        */
        
        return diskPhotoData
    }
    
    func removePhoto(forKey key: String) {
        self.memCache?.removeObject(forKey: key as AnyObject)
        self.ioQueue?.async {
            do {
                try FileManager.default.removeItem(atPath: self.defaultCachePath(forKey: key))
            } catch {
                DDLog("移除Cache文件失败")
            }
        }
    }
    
    func defaultCachePath(forKey key: String) -> String {
        return self.cachePath(forKey: key, inPath: PhotosMessageDir().path)
    }
    
    func getSize() -> UInt {
        var size:UInt = 0
        self.ioQueue?.sync {
            let fileEnumerator = FileManager.default.enumerator(atPath: PhotosMessageDir().absoluteString)
            while let fileName = fileEnumerator?.nextObject() as? String {
                do {
                    let filePath = PhotosMessageDir().appendingPathComponent(fileName)
                    let attrs = try FileManager.default.attributesOfItem(atPath: filePath.absoluteString)
                    size += attrs[FileAttributeKey.size] as! UInt
                } catch {
                    DDLog("获取文件属性出错!")
                }
            }
        }
        
        return size
    }
    
    func getDiskCount() -> Int {
        var count: Int = 0
        self.ioQueue?.sync {
            let fileEnumerator = FileManager.default.enumerator(atPath: PhotosMessageDir().absoluteString)
            while (fileEnumerator?.nextObject() as? String) != nil {
                count += 1
            }
        }
        
        return count
    }
    
    func removePhotoFromNSCache(forKey key: String) {
        self.memCache?.removeObject(forKey: key as AnyObject)
    }
    
    func queryDiskCache(forKey key: String, done: ((Data) -> Void)?) -> Operation? {
        let operation = Operation.init()
        
        if done == nil {
            return nil
        }
        
        // 首先在memory cache中查找
        let photo = self.photoFromMemoryCache(forKey: key)
        if photo != nil {
            done!(photo!)
            return nil
        }
        
        self.ioQueue?.async {
            if operation.isCancelled {
                return
            }
            
            let diskPhotos = self.diskPhoto(forKey: key)
            if diskPhotos != nil {
                self.memCache?.setObject(diskPhotos as AnyObject, forKey: key as AnyObject)
            }
            DispatchQueue.main.async {
                done!(diskPhotos!)
            }
        }
        
        return operation
    }
    
    func getKeyName() -> String {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "YYYYMMddhhmmssSSS"
        let date = formatter.string(from: Date.init())
        return String.init(format: "%@_send", date)
    }
    
    func clearAllCache(closure: @escaping (Bool) -> Void) {
        self.memCache?.removeAllObjects()
        let allImages = self.getAllImageCache()
        if allImages.count == 0 {
            closure(true)
        }
        for (idx, path) in allImages.enumerated() {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch  {
                DDLog("删除文件失败!")
            }
            
            if idx == allImages.count - 1 {
                closure(true)
            }
        }
    }
    
    func getAllImageCache() -> [String] {
        var array = [String]()
        self.ioQueue?.sync {
            let fileEnumerator = FileManager.default.enumerator(atPath: PhotosMessageDir().absoluteString)
            while let fileName = fileEnumerator?.nextObject() as? String {
                array.append(String.init(format: "%@/%@", PhotosMessageDir().absoluteString, fileName))
            }
        }
        return array
    }
    
    private func diskPhoto(forKey key: String) -> Data? {
        let data = self.diskPhotosDataBySearchingAllPaths(forKey: key)
        return data
    }
    
    private func diskPhotosDataBySearchingAllPaths(forKey key: String) -> Data? {
        do {
            let defaultPath = self.defaultCachePath(forKey: key)
            let data = try Data.init(contentsOf: URL.init(fileURLWithPath: defaultPath))
            return data
        } catch {
            DDLog("读取本地磁盘文件失败!")
            return nil
        }
    }
    
    private func photoFromMemoryCache(forKey key: String) -> Data? {
        return self.memCache?.object(forKey: key as AnyObject) as? Data
    }
    
    private func cachePath(forKey key: String, inPath path: String) -> String {
        let fileName = self.cachedFileName(forKey: key)
        return (URL.init(string: path)?.appendingPathComponent(fileName).path)!
    }
    
    private func cachedFileName(forKey key: String) -> String {
        let str = key.cString(using: String.Encoding.utf8)
        let r = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(str, CC_LONG((str?.count)!), r)
        let fileName = String.init(format: "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15])
        
        return fileName
    }
}
