//
//  MTTAvatarManager.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/4/13.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation
import SDWebImage

let DD_AVATAR_ARRAY = "avatarUrlArray"
let DD_AVATAR_LAYOUT = "avatarLayout"

class MTTAvatarManager {
    
    static let sharedInstance = MTTAvatarManager()
    
    private var avatars = [String: Any]()
    private var downloadImages = [Int: UIImage]()
    private var currentAvatarKey: String?
    private var currentLeftImages: Int = 0
    private var currentDownloadImageCorrect: Bool = false
    
    func add(key: String, avatar: [String], forLayout layout: [NSValue]) {
        if self.avatars.keys.contains(key) {
            let object = [DD_AVATAR_ARRAY: avatar, DD_AVATAR_LAYOUT: layout] as [String : Any]
            self.avatars[key] = object
            self
        }
    }
    
    //MARK: - Private
    private func p_startOneGroupAvatarCombination() {
        if self.avatars.count > 0 && self.currentAvatarKey == nil {
            self.currentAvatarKey = Array(self.avatars.keys)[0]
            let avatarUrls = (self.avatars[self.currentAvatarKey!] as! [String: Any])[DD_AVATAR_ARRAY] as! [String]
            UIGraphicsBeginImageContext(CGSize.init(width: 100, height: 100))
            self.currentLeftImages = avatarUrls.count
            self.currentDownloadImageCorrect = true
            weak var weakSelf = self
            for (idx, urlString) in avatarUrls.enumerated() {
                var urlTemp = String.init(format: "%@", urlString)
                if urlTemp.hasSuffix("_100x100.jpg") == false && urlTemp.characters.count > 0 {
                    urlTemp = urlTemp.appending("_100x100.jpg")
                }
                let url = URL.init(string: urlTemp)
                SDWebImageManager.shared().downloadImage(with: url, options: SDWebImageOptions.lowPriority, progress: { (receivedSize: Int, expectedSize: Int) in
                    // 什么都不做
                }, completed: { (image: UIImage?, error: Error?, cacheType: SDImageCacheType, finished: Bool, imageURL: URL?) in
                    weakSelf?.currentLeftImages = (weakSelf?.currentLeftImages)! - 1
                    if image == nil {
                        self.downloadImages[idx] = UIImage.init(withColor: RGB(228, 227, 230), rect: CGRect.init(x: 0, y: 0, width: 100, height: 100))
                        if url != nil && (url?.path.characters.count)! > 0 {
                            self.currentDownloadImageCorrect = false
                        }
                    } else {
                        self.downloadImages[idx] = image
                    }
                    
                    if self.currentLeftImages <= 0 {
                        weakSelf?.p_combinationCompletion()
                    }
                })
            }
        }
    }
    
    private func p_combinationCompletion() {
        if self.currentDownloadImageCorrect {
            UIGraphicsBeginImageContext(CGSize.init(width: 100, height: 100))
            var frames = (self.avatars[self.currentAvatarKey!] as! [String: Any])[DD_AVATAR_LAYOUT] as! [NSValue]
            for (index, image) in self.downloadImages {
                // image = [UIImage roundCorners:image corner:10];      .....可能还需要后续实现
                let frame = frames[index].cgRectValue
                image.draw(in: frame)
            }
            let combinationImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            SDImageCache.shared().store(combinationImage, forKey: self.currentAvatarKey, toDisk: true)
        }
        
        self.p_endCurrentGroupAvatarTaskAndStartNextTask()
    }
    
    private func p_endCurrentGroupAvatarTaskAndStartNextTask() {
        if self.avatars.count > 0 && self.currentAvatarKey != nil {
            self.avatars.removeValue(forKey: self.currentAvatarKey!)
            self.downloadImages.removeAll()
            self.p_startOneGroupAvatarCombination()
        }
    }
}
