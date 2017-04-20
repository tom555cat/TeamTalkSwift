//
//  DDEmotionCell.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/3/13.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class DDEmotionCell: DDChatImageCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.msgImgView?.isUserInteractionEnabled = false
        self.msgImgView?.clipsToBounds = true
        self.msgImgView?.contentMode = .scaleAspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    //MARK: - DDChatCellProtocol
    override func sizeForContent(content: MTTMessageEntity) -> CGSize {
        return CGSize.init(width: 100, height: 133)
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
            return 8.5
        default:
            break
        }
    }
    
    override func contentRightGapWithBubble() -> Float {
        switch self.location {
        case .DDBubbleRight:
            return 6.5
        case .DDBubbleLeft:
            return 1
        default:
            break
        }
    }
    
    override func layoutContentView(content: MTTMessageEntity) {
        let size: CGSize = self.sizeForContent(content: content)
        self.msgImgView?.snp.remakeConstraints({ make in
            make.size.equalTo(size)
            make.top.equalTo((self.bubbleImageView?.snp.top)!).offset(self.contentUpGapWithBubble())
            make.left.equalTo((self.bubbleImageView?.snp.left)!).offset(self.contentLeftGapWithBubble())
        })
    }
    
    override func cellHeightForMessage(message: MTTMessageEntity) -> Float {
        return 133 + Float(dd_bubbleUpDown)
    }
    
    override func setContent(content: MTTMessageEntity) {
        super.setContent(content: content)
        let emotionStr = content.msgContent
        var emotionImageStr = EmotionsModule.sharedInstance.emotionUnicodeDic?[emotionStr] as! String
        emotionImageStr = URL.init(fileURLWithPath: emotionImageStr).deletingPathExtension().path
        let emotion = UIImage.sd_animatedGIFNamed(emotionImageStr)
        if emotion != nil {
            self.msgImgView?.image = emotion
            self.bubbleImageView?.isHidden = true
        }
    }
    
    
    func sendTextAgain(message: MTTMessageEntity) {
        message.state = .DDMessageSending
        self.showSending()
        // 还需继续完善。。。。。。。。。。。。。。。。。。
    }
}
