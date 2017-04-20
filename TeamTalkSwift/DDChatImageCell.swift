//
//  DDChatImageCell.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/3/9.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation
import MWPhotoBrowser
import SDWebImage

typealias DDPreview = () -> Void
typealias DDTapPreview = () -> Void

class DDChatImageCell : DDChatBaseCell, MWPhotoBrowserDelegate {
    
    var msgImgView: UIImageView?
    var photos: [Any]?
    var preview: DDPreview?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.msgImgView = UIImageView.init()
        self.msgImgView?.isUserInteractionEnabled = true
        self.msgImgView?.clipsToBounds = true
        self.msgImgView?.layer.cornerRadius = 5
        self.msgImgView?.contentMode = .scaleAspectFill
        self.contentView.addSubview(self.msgImgView!)
        self.bubbleImageView?.clipsToBounds = true
        self.photos = [Any]()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    func showPreview(inPhotoArray photos: [URL], atIndex index: UInt) {
        self.photos?.removeAll()
        
        for obj in photos {
            self.photos?.append(MWPhoto.init(url: obj))
        }
        
        let browser = MWPhotoBrowser.init(delegate: self)
        browser?.displayActionButton = false
        browser?.displayNavArrows = false
        browser?.zoomPhotosToFill = false
        browser?.setCurrentPhotoIndex(index)
        ChattingMainViewController.sharedInstance.pushViewController(viewController: browser!, animated: true)
        browser?.navigationController?.navigationBar.isHidden = true
    }
    
    override func setContent(content: MTTMessageEntity) {
        // 获取气泡设置
        super.setContent(content: content)
        // 设置气泡位置
        var bubbleImage: UIImage?
        
        switch self.location {
        case .DDBubbleLeft:
            bubbleImage = UIImage.init(named: (self.leftConfig?.picBgImage)!)
            bubbleImage = bubbleImage?.stretchableImage(withLeftCapWidth: Int((self.leftConfig?.imgStretchy.left)!), topCapHeight: Int((self.leftConfig?.imgStretchy.top)!))
            
        case .DDBubbleRight:
            bubbleImage = UIImage.init(named: (self.rightConfig?.picBgImage)!)
            bubbleImage = bubbleImage?.stretchableImage(withLeftCapWidth: Int((self.rightConfig?.imgStretchy.left)!), topCapHeight: Int((self.rightConfig?.imgStretchy.top)!))
        
        default:
            break
        }
        
        self.bubbleImageView?.image = bubbleImage
        if content.msgContentType == .DDMessageTypeImage {
            var messageContent = MTTUtil.jsonStringToDictionary(text: content.msgContent)
            if messageContent == nil {
                var urlString = content.msgContent
                urlString = urlString.replacingOccurrences(of: DD_MESSAGE_IMAGE_PREFIX, with: "")
                urlString = urlString.replacingOccurrences(of: DD_MESSAGE_IMAGE_SUFFIX, with: "")
                var url = URL.init(string: urlString)
                self.showSending()
                self.msgImgView?.sd_setImage(with: url, completed: { (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
                    self.showSendSuccess()
                })
                
                return
            }
            
            if let localPath = messageContent?[DD_IMAGE_LOCAL_KEY] as? String {
                // 加载本地照片
                print(localPath)
                let data = MTTPhotoCache.sharedInstance.photoFromDiskCache(forKey: localPath)
                let image = UIImage.init(data: data!)
                self.msgImgView?.image = image
            } else {
                // 加载服务器上的图片
                let url = messageContent?[DD_IMAGE_URL_KEY] as? String
                weak var weakSelf = self
                
                self.showSending()
                self.msgImgView?.sd_setImage(with: URL.init(string: url!), completed: { (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
                    weakSelf?.showSendSuccess()
                })
            }
        }
    }
    
    //MARK: - DDChatCellProtocol
    override func sizeForContent(content: MTTMessageEntity) -> CGSize {
        var height: CGFloat = 150
        var width: CGFloat = 60
        var urlString = content.msgContent
        urlString = urlString.replacingOccurrences(of: DD_MESSAGE_IMAGE_PREFIX, with: "")
        urlString = urlString.replacingOccurrences(of: DD_MESSAGE_IMAGE_SUFFIX, with: "")
        let url = URL.init(string: urlString)
        let manager = SDWebImageManager.shared()
        if (manager?.cachedImageExists(for: url))! {
            let key = manager?.cacheKey(for: url)
            let curImg = SDImageCache.shared().imageFromDiskCache(forKey: key)
            height = (curImg?.size.height)! > CGFloat(40) ? (curImg?.size.height)! : 40
            width = (curImg?.size.width)! > CGFloat(40) ? (curImg?.size.width)! : 40
            return MTTUtil.sizeTrans(size: CGSize.init(width: width, height: height))
        }
        
        return CGSize.init(width: width, height: height)
    }
    
    override func contentUpGapWithBubble() -> Float {
        return 1
    }
    
    override func contentDownGapWithBubble() -> Float {
        return 1
    }
    
    override func contentLeftGapWithBubble() -> Float {
        switch self.location {
        case .DDBubbleRight:
            return 1
        case .DDBubbleLeft:
            return 6.5
        default:
            return 0
        }
    }
    
    override func contentRightGapWithBubble() -> Float {
        switch self.location {
        case .DDBubbleRight:
            return 6.5
        case .DDBubbleLeft:
            return 1
        default:
            return 0
        }
    }
    
    override func layoutContentView(content: MTTMessageEntity) {
        let size = self.sizeForContent(content: content)
        self.msgImgView?.snp.remakeConstraints({ make in
            make.left.equalTo((self.bubbleImageView?.snp.left)!).offset(self.contentLeftGapWithBubble() + 1)
            make.top.equalTo((self.bubbleImageView?.snp.top)!).offset(self.contentUpGapWithBubble() + 1)
            make.size.equalTo(CGSize.init(width: size.width - 2, height: size.height - 2))
        })
    }
    
    override func cellHeightForMessage(message: MTTMessageEntity) -> Float {
        return 27 + Float(dd_bubbleUpDown)
    }
    
    //MARK: DDMenuImageView Delegate
    override func clickTheSendAgain(imageView: MenuImageView) {
        if self.sendAgain != nil {
            self.sendAgain!()
        }
    }
    
    func sendImageAgain(message: MTTMessageEntity) {
        // 子类去集成
        self.showSending()
        var dic = MTTUtil.jsonStringToDictionary(text: message.msgContent)
        let localPath = dic?[DD_IMAGE_LOCAL_KEY] as! String
        var image = SDImageCache.shared().imageFromDiskCache(forKey: localPath)
        if image == nil {
            let data = MTTPhotoCache.sharedInstance.photoFromDiskCache(forKey: localPath)
            image = UIImage.init(data: data!)
            if image == nil {
                self.showSendFailure()
                return
            }
        }
        
        // ....................还需要DDSendPhotoMessageAPI sharedPhotoCache
        
    }
    
    override func clickThePreview(imageView: MenuImageView) {
        if (self.preview != nil) {
            self.preview!()
        }
    }
    
    //MARK: MWPhotoBrowserDelegate
    // 原版本没有实现
    public func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return 0
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        return nil
    }
}
