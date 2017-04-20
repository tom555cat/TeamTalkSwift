//
//  MenuImageView.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/23.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit

enum DDImageShowMenu: UInt {
    case DDShowEarphonePlay     =   1   //听筒播放
    case DDShowSpeakerPlay      =   2   //扬声器播放
    case DDShowSendAgain        =   4   //重发
    case DDShowCopy             =   8   //复制
    case DDShowPreview          =   16  //图片预览
}

protocol MenuImageViewDelegate {
    func clickTheCopy(imageView: MenuImageView)
    func clickTheEarphonePlay(imageView: MenuImageView)
    func clickTheSpeakerPlay(imageView: MenuImageView)
    func clickTheSendAgain(imageView: MenuImageView)
    func clickThePreview(imageView: MenuImageView)
    func tapTheImageView(imageView: MenuImageView)
}

class MenuImageView: UIImageView {

    var delegate: MenuImageViewDelegate?
    
    var showMenu: DDImageShowMenu?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.attachTapHandler()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.attachTapHandler()
        //fatalError("init(coder:) has not been implemented")
    }
    
    func showTheMenu() {
        self.becomeFirstResponder()
        let copyItem = UIMenuItem.init(title: "复制", action: #selector(copyString(sender:)))
        let sendAgain = UIMenuItem.init(title: "重发", action: #selector(sendAgain(sender:)))
        let earphonePlayItem = UIMenuItem.init(title: "听筒播放", action: #selector(earphonePlay(sender:)))
        let speakerPlayItem = UIMenuItem.init(title: "扬声器播放", action: #selector(speakerPlay(sender:)))
        let previewItem = UIMenuItem.init(title: "预览", action: #selector(imagePreview(sender:)))
        
        let menu = UIMenuController.shared
        menu.menuItems = [copyItem, sendAgain, earphonePlayItem, speakerPlayItem, previewItem]
        menu.setTargetRect(self.frame, in: self.superview!)
        menu.setMenuVisible(true, animated: true)
        DDLog("menuItems: \(menu.menuItems)")
    }
    
    // MARK: Menu Selector
    func earphonePlay(sender: Any) {
        // 听筒播放
        self.delegate?.clickTheEarphonePlay(imageView: self)
    }
    
    func speakerPlay(sender: Any) {
        // 扬声器播放
        self.delegate?.clickTheSpeakerPlay(imageView: self)
    }
    
    func sendAgain(sender: Any) {
        // 重发
        self.delegate?.clickTheSendAgain(imageView: self)
    }
    
    func copyString(sender: Any) {
        // 复制
        self.delegate?.clickTheCopy(imageView: self)
    }
    
    func imagePreview(sender: Any) {
        // 预览
        self.delegate?.clickThePreview(imageView: self)
    }
    
    // MARK: Private Function
    private func attachTapHandler() {
        self.isUserInteractionEnabled = true
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(handleTap(recognizer:)))
        touch.numberOfTapsRequired = 1
        self.addGestureRecognizer(touch)
        
        let press = UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(recognizer:)))
        press.minimumPressDuration = 0.5
        self.addGestureRecognizer(press)
    }
    
    @objc private func handleTap(recognizer: UIGestureRecognizer) {
        self.delegate?.tapTheImageView(imageView: self)
    }
    
    @objc private func longPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            self.showTheMenu()
        }
    }
    
    // 反馈关心的功能
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if ((showMenu?.rawValue)! & DDImageShowMenu.DDShowEarphonePlay.rawValue) != 0 && action == #selector(earphonePlay(sender:))  {
            return true
        } else if ((showMenu?.rawValue)! & DDImageShowMenu.DDShowEarphonePlay.rawValue) != 0 && action == #selector(earphonePlay(sender:)) {
            return true
        } else if ((showMenu?.rawValue)! & DDImageShowMenu.DDShowEarphonePlay.rawValue) != 0 && action == #selector(earphonePlay(sender:)) {
            return true
        } else if ((showMenu?.rawValue)! & DDImageShowMenu.DDShowEarphonePlay.rawValue) != 0 && action == #selector(earphonePlay(sender:)) {
            return true
        } else if ((showMenu?.rawValue)! & DDImageShowMenu.DDShowEarphonePlay.rawValue) != 0 && action == #selector(earphonePlay(sender:)) {
            return true
        }
        return false
    }
}
