//
//  MTTAvatarImageView.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/4/13.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit
import SDWebImage

class MTTAvatarImageView: UIImageView {

    func setAvatar(avatar: String, isGroup group: Bool) {
        self.removeAllSubviews()
        self.image = nil
        if group {
            let image = SDImageCache.shared().imageFromDiskCache(forKey: avatar)
            if image != nil {
                self.image = image
                
            } else {
                let avatarKey = String.init(format: "%@", avatar)
                var avatarTmp = String.init(format: "%@", avatar)
                if avatar.hasSuffix(";") {
                    avatarTmp = avatar.substring(to: avatar.index(avatar.startIndex, offsetBy: avatar.characters.count - 1))
                }
                let avatarArray = avatarTmp.components(separatedBy: ";")
                self.p_setGroupAvatar(avatar: avatarKey, avatarImages: avatarArray)
            }
            
        } else {
            // 只有一个头像
            let avatarURL = URL.init(string: avatar)
            let placeholdImage = UIImage.init(named: "user_placeholder")
            self.sd_setImage(with: avatarURL, placeholderImage: placeholdImage)
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //MARK: - PrivateAPI
    private func p_setGroupAvatar(avatar: String, avatarImages: [String]) {
        let placeholderImage = UIImage.init(named: "user_placeholder")
        let imageViewFrames = self.p_getAvatarLayout(avatarCount: avatarImages.count, scale: 1)
        let frames = self.p_getAvatarLayout(avatarCount: avatarImages.count, scale: 2)
        if frames.count > 0 {
            MTTAvatarManager.sharedInstance.add(key: avatar, avatar: avatarImages, forLayout: frames)
        }
        for index in 0..<imageViewFrames.count {
            let frame = imageViewFrames[index].cgRectValue
            let imageView = UIImageView.init(frame: frame)
            imageView.layer.cornerRadius = 2
            imageView.clipsToBounds = true
            imageView.isUserInteractionEnabled = false
            let avatar = avatarImages[index]
            let url = URL.init(string: avatar)
            imageView.sd_setImage(with: url, placeholderImage: placeholderImage)
            self.addSubview(imageView)
        }
    }
    
    private func p_getAvatarLayout(avatarCount: Int, scale: Int) -> [NSValue] {
        let size = self.p_avatarSize(forCount: avatarCount, forScale: scale)
        let row = self.p_getRow(forCount: avatarCount)
        var frames = [NSValue]()
        for rowIndex in 0..<row {
            let countInRow = self.p_getCount(inRow: rowIndex, avatarCount: avatarCount)
            for index in 0..<countInRow {
                let leftRightGap = self.p_getLeftAndRight(forAvatarCount: avatarCount, forScale: scale)
                let upDownGap = self.p_getUpAndDownGap(forAvatarCount: avatarCount, forScale: scale)
                let startX = self.p_getOriginStartX(forAvatarCount: avatarCount, row: rowIndex, forScale: scale)
                let startY = self.p_getOriginStartY(forAvatarCount: avatarCount, scale: scale)
                let x = startX + leftRightGap * index + index * Int(size.width)
                let y = startY + upDownGap * rowIndex + rowIndex * Int(size.height)
                let frame = CGRect.init(x: x, y: y, width: Int(size.width), height: Int(size.height))
                frames.append(NSValue.init(cgRect: frame))
            }
        }
        
        return frames
    }
    
    private func p_avatarSize(forCount avatarCount: Int, forScale scale: Int) -> CGSize {
        switch avatarCount {
        case 1:
            return CGSize.init(width: 22 * scale, height: 22 * scale)
        case 2:
            return CGSize.init(width: 22 * scale, height: 22 * scale)
        case 3:
            return CGSize.init(width: 22 * scale, height: 22 * scale)
        case 4:
            return CGSize.init(width: 22 * scale, height: 22 * scale)
        case 5:
            return CGSize.init(width: 14 * scale, height: 14 * scale)
        case 6:
            return CGSize.init(width: 14 * scale, height: 14 * scale)
        case 7:
            return CGSize.init(width: 14 * scale, height: 14 * scale)
        case 8:
            return CGSize.init(width: 14 * scale, height: 14 * scale)
        case 9:
            return CGSize.init(width: 14 * scale, height: 14 * scale)
        default:
            return CGSize.init()
        }
    }
    
    private func p_getRow(forCount avatarCount: Int) -> Int {
        switch avatarCount {
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 2
        case 4:
            return 2
        case 5:
            return 2
        case 6:
            return 2
        case 7:
            return 3
        case 8:
            return 3
        case 9:
            return 3
        default:
            return 0
        }
    }
    
    private func p_getCount(inRow row: Int, avatarCount: Int) -> Int {
        if avatarCount <= 4 {
            if avatarCount <= 2 {
                return avatarCount
            } else {
                if row == 0 {
                    return avatarCount % 2 == 0 ? 2 : avatarCount % 2
                } else {
                    return 2
                }
            }
            
        } else {
            if row == 0 {
                return avatarCount % 3 == 0 ? 3 : avatarCount % 3
            } else {
                return 3
            }
        }
    }
    
    private func p_getLeftAndRight(forAvatarCount avatarCount: Int, forScale scale: Int) -> Int {
        return 2 * scale
    }
    
    private func p_getUpAndDownGap(forAvatarCount avatarCount: Int, forScale scale: Int) -> Int {
        switch avatarCount {
        case 1:
            return 0
        case 2:
            return 0
        case 3:
            return 2 * scale
        case 4:
            return 2 * scale
        case 5:
            return 2 * scale
        case 6:
            return 2 * scale
        case 7:
            return 2 * scale
        case 8:
            return 2 * scale
        case 9:
            return 2 * scale
        default:
            return 0
        }
    }
    
    private func p_getOriginStartX(forAvatarCount avatarCount: Int, row: Int, forScale scale: Int) -> Int {
        if avatarCount == 1 || avatarCount == 3 {
            if row == 0 {
                return 14 * scale
            }
        }
        
        if avatarCount == 5 || avatarCount == 8 {
            if row == 0 {
                return 10 * scale
            }
        }
        
        if avatarCount == 7 {
            if row == 0 {
                return 18 * scale
            }
        }
        
        return 2 * scale
    }
    
    private func p_getOriginStartY(forAvatarCount avatarCount: Int, scale: Int) -> Int {
        switch avatarCount {
        case 1:
            return 14 * scale
        case 2:
            return 14 * scale
        case 3:
            return 2 * scale
        case 4:
            return 2 * scale
        case 5:
            return 10 * scale
        case 6:
            return 10 * scale
        case 7:
            return 2 * scale
        case 8:
            return 2 * scale
        case 9:
            return 2 * scale
        default:
            return 0
        }
    }
}
