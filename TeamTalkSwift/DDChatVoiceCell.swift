//
//  DDChatVoiceCell.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/3/13.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

typealias DDEarphonePlay = () -> Void
typealias DDSpearerPlay = () -> Void

let maxCellLength: Float = 180
let minCellLength: Float = 50

class DDChatVoiceCell: DDChatBaseCell {
    
    var voiceImageView: UIImageView?
    var timeLabel: UILabel?
    var playedLabel: UILabel?
    
    var earphonePlay: DDEarphonePlay?
    var speakerPlay: DDSpearerPlay?
    
    private var voicePath: String?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.voiceImageView = UIImageView.init()
        self.contentView.addSubview(self.voiceImageView!)
        
        self.timeLabel = UILabel.init()
        self.timeLabel?.font = UIFont.systemFont(ofSize: 15)
        self.timeLabel?.backgroundColor = UIColor.clear
        self.timeLabel?.textColor = RGB(149, 149, 149)
        self.contentView.addSubview(self.timeLabel!)
        
        self.playedLabel = UILabel.init()
        self.playedLabel?.backgroundColor = UIColor.red
        self.playedLabel?.layer.cornerRadius = 5
        self.playedLabel?.clipsToBounds = true
        self.contentView.addSubview(self.playedLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    override func setContent(content: MTTMessageEntity) {
        super.setContent(content: content)
        
        if let value = content.info?[DDVOICE_PLAYED] as? Int {
            if value > 0 {
                self.playedLabel?.isHidden = true
            } else {
                self.playedLabel?.isHidden = false
            }
        }
        
        self.voicePath = content.msgContent
        var imageArray:[UIImage]?
        
        switch self.location {
        case .DDBubbleLeft:
            imageArray = [UIImage.init(named: "dd_left_voice_one")!, UIImage.init(named: "dd_left_voice_two")!, UIImage.init(named: "dd_left_voice_three")!]
            self.voiceImageView?.contentMode = .left
            self.voiceImageView?.image = UIImage.init(named: "dd_left_voice_three")
            self.activityView?.snp.remakeConstraints({ make in
                make.left.equalTo((self.bubbleImageView?.snp.right)!).offset(20)
            })
        case .DDBubbleRight:
            imageArray = [UIImage.init(named: "dd_right_voice_one")!, UIImage.init(named: "dd_right_voice_two")!, UIImage.init(named: "dd_right_voice_three")!]
            self.voiceImageView?.contentMode = .right
            self.voiceImageView?.image = UIImage.init(named: "dd_right_voice_three")
            self.playedLabel?.isHidden = true
            self.activityView?.snp.remakeConstraints({ make in
                make.right.equalTo((self.bubbleImageView?.snp.left)!).offset(-30)
            })
        default:
            break
        }
        
        var voiceLength = content.info?[VOICE_LENGTH] as? Int32
        if voiceLength == nil {
            voiceLength = 0
        }
        self.voiceImageView?.animationImages = imageArray
        self.voiceImageView?.animationRepeatCount = Int(voiceLength!)
        self.voiceImageView?.animationDuration = 1
        
        var timeLength = content.info![VOICE_LENGTH] as? Int32
        if timeLength == nil {
            timeLength = 0
        }
        let lengthString = String.init(format: "%ld\"", timeLength!)
        self.timeLabel?.text = lengthString
    }
    
    func showVoicePlayed() {
        self.playedLabel?.isHidden = true
    }
    
    func stopVoicePlayAnimation() {
        self.voiceImageView?.stopAnimating()
    }
    
    
    //MARK: DDChatCellProtocol
    override func sizeForContent(content: MTTMessageEntity) -> CGSize {
        var voiceLength = content.info?[VOICE_LENGTH] as? Int32
        if voiceLength == nil {
            voiceLength = 0
        }
        let width = self.lengthForVoiceLength(voiceLength: Float(voiceLength!))
        return CGSize.init(width: CGFloat(width), height: 17)
    }
    
    override func contentUpGapWithBubble() -> Float {
        switch self.location {
        case .DDBubbleRight:
            return (self.rightConfig?.voiceInset.top)!
        case .DDBubbleLeft:
            return (self.leftConfig?.voiceInset.top)!
        default:
            break
        }
    }
    
    override func contentDownGapWithBubble() -> Float {
        switch self.location {
        case .DDBubbleRight:
            return (self.rightConfig?.voiceInset.bottom)!
        case .DDBubbleLeft:
            return (self.leftConfig?.voiceInset.bottom)!
        default:
            break
        }
    }
    
    override func contentLeftGapWithBubble() -> Float {
        switch self.location {
        case .DDBubbleRight:
            return (self.rightConfig?.voiceInset.left)!
        case .DDBubbleLeft:
            return (self.leftConfig?.voiceInset.left)!
        default:
            break
        }
    }
    
    override func contentRightGapWithBubble() -> Float {
        switch self.location {
        case .DDBubbleRight:
            return (self.rightConfig?.voiceInset.right)!
        case .DDBubbleLeft:
            return (self.leftConfig?.voiceInset.right)!
        default:
            break
        }
    }
    
    override func layoutContentView(content: MTTMessageEntity) {
        
        switch self.location {
        case .DDBubbleLeft:
            self.voiceImageView?.snp.remakeConstraints({ make in
                make.size.equalTo(CGSize.init(width: 11, height: 17))
                make.left.equalTo((self.bubbleImageView?.snp.left)!).offset(15)
                make.top.equalTo((self.bubbleImageView?.snp.top)!).offset(self.contentUpGapWithBubble())
            })
            
            self.timeLabel?.textAlignment = .left
            self.timeLabel?.snp.remakeConstraints({ make in
                make.size.equalTo(CGSize.init(width: 20, height: 15))
                make.bottom.equalTo((self.bubbleImageView?.snp.bottom)!).offset(0)
                make.left.equalTo((self.bubbleImageView?.snp.right)!).offset(10)
            })
            
            self.playedLabel?.snp.remakeConstraints({ make in
                make.size.equalTo(CGSize.init(width: 10, height: 10))
                make.top.equalTo((self.bubbleImageView?.snp.top)!).offset(2)
                make.left.equalTo((self.bubbleImageView?.snp.right)!).offset(10)
            })
        
        case .DDBubbleRight:
            self.voiceImageView?.snp.remakeConstraints({ make in
                make.size.equalTo(CGSize.init(width: 11, height: 17))
                make.right.equalTo((self.bubbleImageView?.snp.right)!).offset(-15)
                make.top.equalTo((self.bubbleImageView?.snp.top)!).offset(self.contentUpGapWithBubble())
            })
            
            self.timeLabel?.textAlignment = .right
            self.timeLabel?.snp.remakeConstraints({ make in
                make.size.equalTo(CGSize.init(width: 20, height: 15))
                make.bottom.equalTo((self.bubbleImageView?.snp.bottom)!).offset(0)
                make.right.equalTo((self.bubbleImageView?.snp.left)!).offset(-10)
            })
            
            self.playedLabel?.snp.remakeConstraints({ make in
                make.size.equalTo(CGSize.init(width: 10, height: 10))
                make.top.equalTo((self.bubbleImageView?.snp.top)!).offset(2)
                make.right.equalTo((self.bubbleImageView?.snp.left)!).offset(-10)
            })
        default:
            break
        }
    }
    
    override func cellHeightForMessage(message: MTTMessageEntity) -> Float {
        return 27 + Float(dd_bubbleUpDown)
    }
    
    //MARK: PrivateAPI
    private func lengthForVoiceLength(voiceLength: Float) -> Float {
        let gap = maxCellLength - minCellLength
        if voiceLength > 10 {
            return maxCellLength
        } else {
            let length = (gap / 10) * voiceLength + minCellLength
            return length
        }
    }
    
    //MARK: DDMenuImageView Delegate
    override func clickTheCopy(imageView: MenuImageView) {
        // 子类去继承
    }
    
    override func clickTheEarphonePlay(imageView: MenuImageView) {
        self.voiceImageView?.startAnimating()
        if self.earphonePlay != nil {
            self.earphonePlay!()
        }
    }
    
    override func clickTheSpeakerPlay(imageView: MenuImageView) {
        self.voiceImageView?.startAnimating()
        if self.speakerPlay != nil {
            self.speakerPlay!()
        }
    }
    
    override func clickTheSendAgain(imageView: MenuImageView) {
        if self.sendAgain != nil {
            self.sendAgain!()
        }
    }
    
    override func tapTheImageView(imageView: MenuImageView) {
        if (self.voiceImageView?.isAnimating)! == false {
            self.voiceImageView?.startAnimating()
            super.tapTheImageView(imageView: imageView)
        } else {
            self.voiceImageView?.stopAnimating()
            super.tapTheImageView(imageView: imageView)
        }
    }
    
    func sendVoiceAgain(message: MTTMessageEntity) {
        // 还需后续完成.............................
    }

}
