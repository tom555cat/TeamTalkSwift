//
//  DDContactsCell.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/4/13.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit

class DDContactsCell: UITableViewCell {

    @IBOutlet weak var avatar: MTTAvatarImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.avatar.contentMode = .scaleAspectFill
        self.avatar.clipsToBounds = true
        self.avatar.layer.cornerRadius = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellContent(avatar: String?, name: String) {
        self.nameLabel.text = name
        let placeholder = UIImage.init(named: "user_placeholder")
        if avatar == nil {
            self.avatar.image = placeholder
        } else {
            self.avatar.sd_setImage(with: URL.init(string: avatar!), placeholderImage: placeholder)
        }
    }
    
    func setGroupAvatar(group: MTTGroupEntity) {
        var ids = [String]()
        var avatars = [String]()
        let data = Array(group.groupUserIds!.reversed())
        if (group.groupUserIds?.count)! >= 9 {
            for i in 0..<9 {
                ids.append(data[i])
            }
        } else {
            for i in 0..<data.count {
                ids.append(data[i])
            }
        }
        
        for userID in ids {
            DDUserModule.sharedInstance.getUserFor(userID: userID, block: { (user: MTTUserEntity?) in
                if user != nil {
                    let avatarTmp = user?.getAvatarUrl()
                    avatars.append(avatarTmp!)
                }
            })
        }
        
        self.avatar.setAvatar(avatar: avatars.joined(separator: ";"), isGroup: true)
    }

}
