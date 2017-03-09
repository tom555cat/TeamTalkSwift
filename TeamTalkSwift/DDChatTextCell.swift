//
//  DDChatTextCell.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/27.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

let fontSize = 16

class DDChatTextCell: DDChatBaseCell, TTTAttributedLabelDelegate {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentLabel?.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        self.contentLabel?.numberOfLines = 0
        self.contentLabel?.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.contentLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func setContent(content: MTTMessageEntity) {
        
        super.setContent(content: content)

        // 过滤空格回车
        let labelContent = content.msgContent.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.contentLabel?.text = labelContent
        
        // 设置全局字体颜色
        var linkColor: UIColor?
        var textColor: UIColor?
        switch self.location {
    
        case .DDBubbleLeft:
            linkColor = self.leftConfig?.linkColor
            textColor = self.leftConfig?.textColor
        
        case .DDBubbleRight:
            linkColor = self.rightConfig?.linkColor
            textColor = self.rightConfig?.textColor
            
        default:
            break
        }
        self.contentLabel?.textColor = textColor
        
        // link字符样式
        var linkAttributes = [String: Any]()
        linkAttributes[kCTUnderlineStyleAttributeName as String] = true
        linkAttributes[kCTForegroundColorAttributeName as String] = linkColor?.cgColor
        self.contentLabel?.linkAttributes = linkAttributes
        
        // 点击link样式
        var mutableActiveLinkAttributes = [String: Any]()
        mutableActiveLinkAttributes[kCTUnderlineStyleAttributeName as String] = false
        mutableActiveLinkAttributes[kCTForegroundColorAttributeName as String] = linkColor?.cgColor
        self.contentLabel?.activeLinkAttributes = mutableActiveLinkAttributes
        
        // url识别
        let nsLabelContent = NSString.init(string: labelContent)
        let match = self.checkUrl(string: labelContent)
        for per in match {
            var urlString = nsLabelContent.substring(with: per.range)
            if urlString.range(of: "http") == nil {
                urlString = "http://".appending(urlString)
            }
            let url = URL.init(string: urlString)
            self.contentLabel?.addLink(to: url, with: per.range)
        }
        
        // 花名识别以后再说
        // ...
        
        // 手机号码识别
        // ...
        
        // 邮箱识别
        // ...
    }
    
    // MARK: - DDChatCellProtocol
    override func sizeForContent(content: MTTMessageEntity) -> CGSize {
        let message = content.msgContent.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let nsMessage = NSString.init(string: message)
        var size = nsMessage.boundingRect(with: CGSize.init(width: MAX_CHAT_TEXT_WIDTH, height: 1000000), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(fontSize))], context: nil)
        if size.size.width > MAX_CHAT_TEXT_WIDTH {
            return CGSize.init(width: MAX_CHAT_TEXT_WIDTH, height: size.size.height)
        }
        size.size.height = size.size.height + 1
        size.size.width = size.size.width + 1
        return size.size
    }
    
    override func contentUpGapWithBubble() -> Float {
        switch self.location {
        case .DDBubbleLeft:
            return (self.leftConfig?.inset.top)!
        case .DDBubbleRight:
            return (self.rightConfig?.inset.top)!
        }
    }
    
    override func contentDownGapWithBubble() -> Float {
        switch self.location {
        case .DDBubbleLeft:
            return (self.leftConfig?.inset.bottom)!
        case .DDBubbleRight:
            return (self.rightConfig?.inset.bottom)!
        }
    }
    
    override func contentLeftGapWithBubble() -> Float {
        switch self.location {
        case .DDBubbleLeft:
            return (self.leftConfig?.inset.left)!
        case .DDBubbleRight:
            return (self.rightConfig?.inset.left)!
        }
    }
    
    override func contentRightGapWithBubble() -> Float {
        switch self.location {
        case .DDBubbleLeft:
            return (self.leftConfig?.inset.right)!
        case .DDBubbleRight:
            return (self.rightConfig?.inset.right)!
        }
    }
    
    override func layoutContentView(content: MTTMessageEntity) {
        let size = self.sizeForContent(content: content)
        self.contentLabel?.snp.makeConstraints({ make in
            make.left.equalTo((self.bubbleImageView?.snp.left)!).offset(self.contentLeftGapWithBubble())
            make.top.equalTo((self.bubbleImageView?.snp.top)!).offset(self.contentUpGapWithBubble())
            make.size.equalTo(CGSize.init(width: size.width+1, height: size.height+1))
        })
    }
    
    override func cellHeightForMessage(message: MTTMessageEntity) -> Float {
        super.cellHeightForMessage(message: message)
        let size = self.sizeForContent(content: message)
        let height = self.contentUpGapWithBubble() + self.contentDownGapWithBubble() + Float(size.height) + Float(dd_bubbleUpDown)
        return height
     }
    
    // MARK: - DDMenuImageView Delegate
    
    override func clickTheCopy(imageView: MenuImageView) {
        let pboard = UIPasteboard.general
        pboard.string = self.contentLabel?.text
    }
    
    override func clickTheEarphonePlay(imageView: MenuImageView) {
        
    }
    
    override func clickTheSpeakerPlay(imageView: MenuImageView) {
        
    }
    
    override func clickTheSendAgain(imageView: MenuImageView) {
        if (self.sendAgain != nil) {
            self.sendAgain!()
        }
    }
    
    override func tapTheImageView(imageView: MenuImageView) {
        super.tapTheImageView(imageView: imageView)
    }
    
    func sendTextAgain(message: MTTMessageEntity) {
        message.state = .DDMessageSending
        self.showSending()
        
        /*  DDMessageSendManager以后再做
        [[DDMessageSendManager instance] sendMessage:message isGroup:[message isGroupMessage]  Session:[[SessionModule instance] getSessionById:message.sessionId] completion:^(MTTMessageEntity* theMessage,NSError *error) {
            [self showSendSuccess];
            } Error:^(NSError *error) {
            [self showSendFailure];
            }];
        */
    }
    
    // MARK: - Private Function
    func checkUrl(string: String) -> [NSTextCheckingResult] {
        do {
            let regex = try NSRegularExpression.init(pattern: URL_REGULA, options: .caseInsensitive)
            let matches = regex.matches(in: string, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSRange.init(location: 0, length: string.characters.count))
            return matches
        } catch {
            DDLog("检测URL正则表达式出错!")
            return [NSTextCheckingResult]()
        }
    }
}
