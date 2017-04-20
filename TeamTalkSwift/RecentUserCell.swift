//
//  RecentUserCell.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2016/12/29.
//  Copyright © 2016年 Hello World Corporation. All rights reserved.
//

import UIKit

class RecentUserCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var bottomLine: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var lastmessageLabel: UILabel!
    
    @IBOutlet weak var unreadMessageCountLabel: UILabel!
    
    @IBOutlet weak var shiledUnreadMessageCountLabel: UILabel!
    
    @IBOutlet weak var shiledImageView: UIImageView!
    
    /*
    class func recentUserCell(_ tableView: UITableView) -> RecentUserCell {
        let identifier = "RecentUserCell"
        let nib = UINib.init(nibName: "Recent", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: identifier)
        return tableView.dequeueReusableCell(withIdentifier: identifier) as! RecentUserCell
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.layer.cornerRadius = 4.0
        
        self.unreadMessageCountLabel.clipsToBounds = true
        self.unreadMessageCountLabel.layer.cornerRadius = 9
        
        self.shiledUnreadMessageCountLabel.clipsToBounds = true
        self.shiledUnreadMessageCountLabel.layer.cornerRadius = 5
        self.shiledUnreadMessageCountLabel.isHidden = true
        
        self.shiledImageView.image = UIImage.init(named: "shielded")
    }
    
    func setName(name: String) {
        self.nameLabel.text = name
    }
    
    func setTimeStamp(timeStamp: TimeInterval) {
        let date = Date.init(timeIntervalSince1970: timeStamp)
        let dateString = date.description
        self.dateLabel.text = dateString
    }
    
    func setLastMessage(message: String) {
        self.lastmessageLabel.text = message
    }
    
    func setAvatar(avatar: String) {
        for view in self.avatarImageView.subviews {
            view.removeFromSuperview()
        }
        
        let avatarURL = URL.init(string: avatar)
        let placeHolder = UIImage.init(named: "user_placeholder")
        //[_avatarImageView sd_setImageWithURL:avatarURL placeholderImage:placeholder];
        self.avatarImageView.image = placeHolder
    }
    
    func setUnReadMessageCount(messageCount: Int) {
        if messageCount == 0 {
            self.unreadMessageCountLabel.isHidden = true
        } else if messageCount < 10 {
            self.unreadMessageCountLabel.isHidden = false
            let center = self.unreadMessageCountLabel.center
            let title = String.init(format: "%d", messageCount)
            self.unreadMessageCountLabel.text = title
            self.unreadMessageCountLabel.setWidth(width: 16)
            self.unreadMessageCountLabel.center = center
            self.unreadMessageCountLabel.layer.cornerRadius = 8
        } else if messageCount < 99 {
            self.unreadMessageCountLabel.isHidden = false
            let center = self.unreadMessageCountLabel.center
            let title = String.init(format: "%d", messageCount)
            self.unreadMessageCountLabel.text = title
            self.unreadMessageCountLabel.setWidth(width: 25)
            self.unreadMessageCountLabel.center = center
            self.unreadMessageCountLabel.layer.cornerRadius = 8
        } else {
            self.unreadMessageCountLabel.isHidden = false
            let center = self.unreadMessageCountLabel.center
            let title = "99+"
            self.unreadMessageCountLabel.text = title
            self.unreadMessageCountLabel.setWidth(width: 34)
            self.unreadMessageCountLabel.center = center
            self.unreadMessageCountLabel.layer.cornerRadius = 8
        }
    }
    
    func setShowSession(session: MTTSessionEntity) {
        self.setName(name: session.name)
        if session.lastMsg != nil {
            if ((session.lastMsg?.range(of: DD_MESSAGE_IMAGE_PREFIX)) != nil) {
                let array = session.lastMsg?.components(separatedBy: DD_MESSAGE_IMAGE_PREFIX)
                let string = array?.last
                if string?.range(of: DD_MESSAGE_IMAGE_PREFIX) != nil {
                    self.setLastMessage(message: "[图片]")
                } else {
                    self.setLastMessage(message: string!)
                }
            } else if (session.lastMsg?.hasSuffix(".spx"))! {
                self.setLastMessage(message: "[语音]")
            } else {
                self.setLastMessage(message: session.lastMsg!)
            }
        }
        
        if session.sessionType == .single {
            self.avatarImageView.backgroundColor = UIColor.clear
            DDUserModule.sharedInstance.getUserFor(userID: session.sessionID, block: { (user: MTTUserEntity?) in
                for view in self.avatarImageView.subviews {
                    view.removeFromSuperview()
                }
                self.avatarImageView.image = nil
                self.setAvatar(avatar: (user?.getAvatarUrl())!)
            })
        } else {
            self.avatarImageView.backgroundColor = UIColor.init(red: 228/255.0, green: 227/255.0, blue: 230/255.0, alpha: 1)
            self.avatarImageView.image = nil
            for view in self.avatarImageView.subviews {
                view.removeFromSuperview()
            }
            
            self.loadGroupIcon(session: session)
        }
        
        self.shiledUnreadMessageCountLabel.isHidden = true
        self.setUnReadMessageCount(messageCount: session.unReadMsgCount)
        self.shiledImageView.isHidden = true
        if session.isGroup() {
            let group = DDGroupModule.sharedInstance.getGroup(byGroupID: session.sessionID)
            if group != nil {
                if (group?.isShield)! {
                    if session.unReadMsgCount > 0 {
                        self.setShiledUnreadMessage()
                    }
                    self.shiledImageView.isHidden = false
                }
            }
        }
        
        self.setTimeStamp(timeStamp: session.timeInterval)
        if session.unReadMsgCount > 0 {
            // 实时获取未读消息从接口
        }
    }
    
    private func loadGroupIcon(session: MTTSessionEntity) {
        DDGroupModule.sharedInstance.getGroupInfo(groupID: session.sessionID) { (group: MTTGroupEntity) in
            self.setName(name: group.name)
            var ids = [String]()
            var avatars = [String]()
            let data = Array((group.groupUserIds?.reversed())!)
            if (data.count) > 9 {
                for i in 0..<9 {
                    ids.append(data[i])
                }
            } else {
                for i in 0..<data.count {
                    ids.append(data[i])
                }
            }
            
            for (_, userID) in ids.enumerated() {
                DDUserModule.sharedInstance.getUserFor(userID: userID, block: { (user: MTTUserEntity?) in
                    avatars.append((user?.getAvatarUrl())!)
                })
            }
            
            //[_avatarImageView setAvatar:[avatars componentsJoinedByString:@";"] group:1];
            // 需要自定义avatarImageView, 等以后再做
        }
    }
    
    private func setShiledUnreadMessage() {
        self.unreadMessageCountLabel.isHidden = true
        self.shiledUnreadMessageCountLabel.isHidden = false
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
