//
//  MTTUserInfoCell.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/4/19.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit

class MTTUserInfoCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cnameLabel: UILabel!

    func setCellContent(avatar: String, name: String, cname: String) {
        let placeholder = UIImage.init(named: "user_placeholder")
        self.avatar.sd_setImage(with: URL.init(string: avatar), placeholderImage: placeholder)
        self.nameLabel.text = cname
        self.cnameLabel.text = name
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.avatar.clipsToBounds = true
        self.avatar.layer.cornerRadius = 4.0
        
        self.selectedBackgroundView = UIView.init(frame: self.frame)
        self.selectedBackgroundView?.backgroundColor = RGB(244, 245, 246)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
