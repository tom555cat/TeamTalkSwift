//
//  DDChatImageCell.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/3/9.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation
import MWPhotoBrowser

typealias DDPreview = () -> Void
typealias DDTapPreview = () -> Void

class DDChatImageCell : DDChatBaseCell, DDChatCellProtocol, MWPhotoBrowserDelegate {
    
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
        
        var browser = MWPhotoBrowser.init(delegate: self)
        browser?.displayActionButton = false
        browser?.displayNavArrows = false
        browser?.zoomPhotosToFill = false
        browser?.setCurrentPhotoIndex(index)
        ChattingMainViewController.sharedInstance.push
    }
    
    func sendImageAgain(message: MTTMessageEntity) {
        
    }
    
}
