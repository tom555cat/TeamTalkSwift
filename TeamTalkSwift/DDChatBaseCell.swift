//
//  DDChatBaseCell.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/23.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

let dd_avatarEdge: CGFloat = 10                 // 头像到边缘的距离
let dd_avatarBubbleGap: CGFloat = 5             // 头像和气泡之间的距离
let dd_bubbleUpDown: CGFloat = 20               // 气泡到上下边缘的距离

typealias DDSendAgain = () -> Void
typealias DDTapInBubble = () -> Void

enum DDBubbleLocationType: UInt {
    case DDBubbleLeft
    case DDBubbleRight
}

class DDChatBaseCell: UITableViewCell, DDChatCellProtocol, MenuImageViewDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentLabel = TTTAttributedLabel.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        self.contentLabel?.isUserInteractionEnabled = true
        let press = UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(recognizer:)))
        press.minimumPressDuration = 0.5
        self.contentLabel?.addGestureRecognizer(press)
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        self.userAvatar = UIImageView.init()
        self.userAvatar?.isUserInteractionEnabled = true
        self.userAvatar?.contentMode = .scaleAspectFill
        self.userAvatar?.clipsToBounds = true
        self.userAvatar?.layer.cornerRadius = 20
        let openProfile = UITapGestureRecognizer.init(target: self, action: #selector(openProfilePage))
        self.userAvatar?.addGestureRecognizer(openProfile)
        self.contentView.addSubview(self.userAvatar!)
        
        self.userName = UILabel.init()
        self.userName?.backgroundColor = UIColor.clear
        self.userName?.font = UIFont.systemFont(ofSize: 11)
        self.userName?.textColor = RGB(102, 102, 102)
        //self.userName.textAlignment = .top      //以后再进行扩展
        self.contentView.addSubview(self.userName!)
        self.userName?.snp.remakeConstraints { make in
            make.size.equalTo(CGSize.init(width: 200, height: 15))
            make.top.equalTo(0)
            make.left.equalTo((self.userAvatar?.snp.right)!).offset(13)
        }
        
        self.bubbleImageView = MenuImageView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        self.bubbleImageView?.tag = 1000
        self.bubbleImageView?.delegate = self
        self.bubbleImageView?.isUserInteractionEnabled = true
        self.contentView.addSubview(self.bubbleImageView!)
        
        self.activityView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        self.activityView?.hidesWhenStopped = true
        self.activityView?.isHidden = true
        self.contentView.addSubview(self.activityView!)
        
        self.sendFailuredImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 20, height: 20))
        self.sendFailuredImageView?.isHidden = true
        self.contentView.autoresizesSubviews = false     // 这个属性不知是干什么的
        self.sendFailuredImageView?.isUserInteractionEnabled = true
        self.contentView.addSubview(self.sendFailuredImageView!)
        self.sendFailuredImageView?.image = UIImage.init(named: "dd_send_failed")
        let pan = UITapGestureRecognizer.init(target: self, action: #selector(clickTheSendAgain(recognizer:)))
        self.sendFailuredImageView?.addGestureRecognizer(pan)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showSendFailure() {
        self.activityView?.stopAnimating()
        self.sendFailuredImageView?.isHidden = false
        let showMenu = (self.bubbleImageView?.showMenu?.rawValue)! | DDImageShowMenu.DDShowSendAgain.rawValue
        self.bubbleImageView?.showMenu = DDImageShowMenu(rawValue: showMenu)
    }
    
    func showSendSuccess() {
        self.activityView?.stopAnimating()
        self.sendFailuredImageView?.isHidden = true
    }
    
    func showSending() {
        self.activityView?.startAnimating()
        self.sendFailuredImageView?.isHidden = true
    }
    
    func setContent(content: MTTMessageEntity) {
        
        // 获取气泡设置
        self.leftConfig = MTTBubbleModule.sharedInstance.getBubbleConfigLeft(left: true)
        self.rightConfig = MTTBubbleModule.sharedInstance.getBubbleConfigLeft(left: false)
        
        // 设置头像位置
        switch self.location {
        case .DDBubbleLeft:
            self.userAvatar?.snp.remakeConstraints({ make in
                make.size.equalTo(CGSize.init(width: 40, height: 40))
                make.top.equalTo(0)
                make.left.equalTo(dd_avatarEdge)
            })
        case .DDBubbleRight:
            self.userAvatar?.snp.remakeConstraints({ make in
                make.size.equalTo(CGSize.init(width: 40, height: 40))
                make.top.equalTo(0)
                make.right.equalTo(-dd_avatarEdge)
            })
        }
        
        // 设置头像和昵称
        self.currentUserID = content.senderId
        DDUserModule.sharedInstance.getUserFor(userID: content.senderId) { (user: MTTUserEntity?) in
            let avatarURL = URL.init(string: (user?.getAvatarUrl())!)
            self.userAvatar?.sd_setImage(with: avatarURL, placeholderImage: UIImage.init(named: "user_placeholder"))
            self.userName?.text = user?.nick
        }
        
        // 设置昵称是否隐藏
        if self.session?.sessionType == .single || self.location == .DDBubbleRight {
            self.userName?.snp.remakeConstraints({ make in
                make.height.equalTo(0)
            })
            self.userName?.isHidden = true
        } else {
            self.userName?.snp.remakeConstraints({ make in
                make.height.equalTo(15)
            })
            self.userName?.isHidden = false
        }
        
        // 设置气泡相关
        let cell = self as DDChatCellProtocol
        let size = cell.sizeForContent(content: content)
        let bubbleheight = cell.contentUpGapWithBubble() + Float(size.height) + cell.contentDownGapWithBubble()
        let bubbleWidth = cell.contentLeftGapWithBubble() + Float(size.width) + cell.contentRightGapWithBubble()
        
        var bubbleImage: UIImage?
        switch self.location {
        case .DDBubbleLeft:
            bubbleImage = UIImage.init(named: (self.leftConfig?.textBgImage)!)
            bubbleImage = bubbleImage?.stretchableImage(withLeftCapWidth: Int((self.leftConfig?.stretchy.left)!), topCapHeight: Int((self.leftConfig?.stretchy.top)!))
            self.bubbleImageView?.snp.remakeConstraints({ make in
                make.left.equalTo((self.userAvatar?.snp.right)!).offset(dd_avatarBubbleGap)
                make.top.equalTo((self.userName?.snp.bottom)!).offset(0)
                make.size.equalTo(CGSize.init(width: CGFloat(bubbleWidth), height: CGFloat(bubbleheight)))
            })
            
        case .DDBubbleRight:
            bubbleImage = UIImage.init(named: (self.rightConfig?.textBgImage)!)
            bubbleImage = bubbleImage?.stretchableImage(withLeftCapWidth: Int((self.rightConfig?.stretchy.left)!), topCapHeight: Int((self.rightConfig?.stretchy.top)!))
            self.bubbleImageView?.snp.remakeConstraints({ make in
                make.right.equalTo((self.userAvatar?.snp.left)!).offset(-dd_avatarBubbleGap)
                make.top.equalTo((self.userName?.snp.bottom)!).offset(0)
                make.size.equalTo(CGSize.init(width: CGFloat(bubbleWidth), height: CGFloat(bubbleheight)))
            })
        }
        self.bubbleImageView?.image = bubbleImage
        
        // 设置菊花位置
        switch self.location {
        case .DDBubbleLeft:
            self.activityView?.snp.remakeConstraints({ make in
                make.left.equalTo((self.bubbleImageView?.snp.right)!).offset(10)
                make.bottom.equalTo((self.bubbleImageView?.snp.bottom)!)
            })
            self.sendFailuredImageView?.snp.remakeConstraints({ make in
                make.left.equalTo((self.bubbleImageView?.snp.right)!).offset(10)
                make.bottom.equalTo((self.bubbleImageView?.snp.bottom)!)
            })
            
        case .DDBubbleRight:
            self.activityView?.snp.remakeConstraints({ make in
                make.right.equalTo((self.bubbleImageView?.snp.left)!).offset(-10)
                make.bottom.equalTo((self.bubbleImageView?.snp.bottom)!)
            })
            self.sendFailuredImageView?.snp.remakeConstraints({ make in
                make.right.equalTo((self.bubbleImageView?.snp.left)!).offset(-10)
                make.bottom.equalTo((self.bubbleImageView?.snp.bottom)!)
            })
        }
        
        var showMenu: UInt = 0
        
        switch content.state {
        case .DDMessageSending:
            self.activityView?.startAnimating()
            self.sendFailuredImageView?.isHidden = true
        case .DDMessageSendFailure:
            self.activityView?.stopAnimating()
            self.sendFailuredImageView?.isHidden = false
            showMenu = DDImageShowMenu.DDShowSendAgain.rawValue
        case .DDMessageSendSuccess:
            self.activityView?.stopAnimating()
            self.sendFailuredImageView?.isHidden = true
        }
        
        // 设置菜单
        switch content.msgContentType {
        case .DDMessageTypeImage:
            showMenu = showMenu | DDImageShowMenu.DDShowPreview.rawValue
        case .DDMessageTypeText:
            showMenu = showMenu | DDImageShowMenu.DDShowCopy.rawValue
        case .DDMessageTypeVoice:
            showMenu = showMenu | DDImageShowMenu.DDShowEarphonePlay.rawValue | DDImageShowMenu.DDShowSpeakerPlay.rawValue
        default:
            break
        }
        self.bubbleImageView?.showMenu = DDImageShowMenu(rawValue: showMenu)
        
        // 设置内容位置
        cell.layoutContentView(content: content)
    }
    
    // MARK: - Action
    
    func longPress(recognizer: UIGestureRecognizer) {
        self.bubbleImageView?.showTheMenu()
    }
    
    func clickTheSendAgain(recognizer: UIGestureRecognizer) {
        let alertController = UIAlertController.init(title: "重发", message: "是否重新发送此消息", preferredStyle: .actionSheet)
        let okAction = UIAlertAction.init(title: "确定", style: .default) { (UIAlertAction) in
            //self.clickTheSendAgain(imageView: nil)
        }
        alertController.addAction(okAction)
    }
    
    func openProfilePage() {
        if (self.currentUserID != nil) {
            DDUserModule.sharedInstance.getUserFor(userID: self.currentUserID!, block: { (user: MTTUserEntity?) in
                /*   以后再添加
                 PublicProfileViewControll *public = [PublicProfileViewControll new];
                 public.user=user;
                 [[ChattingMainViewController shareInstance] pushViewController:public animated:YES];
                */
            })
        }
    }
    
    // MARK: - DDChatCellProtocol
    func sizeForContent(content: MTTMessageEntity) -> CGSize {
        return CGSize.init(width: 0, height: 0)
    }
    
    func contentUpGapWithBubble() -> Float {
        return 0
    }
    
    func contentDownGapWithBubble() -> Float {
        return 0
    }
    
    func contentLeftGapWithBubble() -> Float {
        return 0
    }
    
    func contentRightGapWithBubble() -> Float {
        return 0
    }
    
    func layoutContentView(content: MTTMessageEntity) {
        
    }
    
    func cellHeightForMessage(message: MTTMessageEntity) -> Float {
        self.leftConfig = MTTBubbleModule.sharedInstance.getBubbleConfigLeft(left: true)
        self.rightConfig = MTTBubbleModule.sharedInstance.getBubbleConfigLeft(left: false)
        return 0
    }
    
    // MARK: - DDMenuImageViewDelegate
    func clickTheCopy(imageView: MenuImageView) {
        // 子类去继承
    }
    
    func clickTheEarphonePlay(imageView: MenuImageView) {
        // 子类去继承
    }
    
    func clickTheSpeakerPlay(imageView: MenuImageView) {
        // 子类去继承
    }
    
    func clickTheSendAgain(imageView: MenuImageView) {
        // 子类去继承
    }
    
    func clickThePreview(imageView: MenuImageView) {
        // 子类去继承
    }
    
    func tapTheImageView(imageView: MenuImageView) {
        if self.tapInBubble != nil {
            self.tapInBubble!()
        }
    }
    
    // MARK: - Property
    var location: DDBubbleLocationType = .DDBubbleLeft
    var bubbleImageView: MenuImageView?
    var userAvatar: UIImageView?
    var userName: UILabel?
    var activityView: UIActivityIndicatorView?
    var sendFailuredImageView: UIImageView?
    var sendAgain: DDSendAgain?
    var tapInBubble: DDTapInBubble?
    var leftConfig: MTTBubbleConfig?
    var rightConfig: MTTBubbleConfig?
    var contentLabel: TTTAttributedLabel?
    var session: MTTSessionEntity?
    
    private var currentUserID: String?
}
