//
//  MTTBaseCell.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/4/19.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit

typealias ChangeSwitch = (Bool) -> Void

class MTTBaseCell: UITableViewCell {

    var desc: UILabel?
    var detail: UILabel?
    var topBorder: UIView?
    var bottomBorder: UIView?
    var switchIcon: UISwitch?
    
    var changeSwitch: ChangeSwitch?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    private func setup() {
        self.topBorder = UIView.init()
        self.topBorder?.backgroundColor = RGB(299, 299, 299)
        self.contentView.addSubview(self.topBorder!)
        self.textLabel?.backgroundColor = UIColor.clear
        
        self.topBorder?.snp.makeConstraints({ make in
            make.left.equalTo(15)
            make.top.equalTo(0)
            make.width.equalTo(self.contentView)
            make.height.equalTo(0.5)
        })
        
        self.topBorder?.isHidden = true
        
        self.bottomBorder = UIView.init()
        self.bottomBorder?.backgroundColor = RGB(299, 299, 299)
        self.contentView.addSubview(self.bottomBorder!)
        
        self.bottomBorder?.snp.makeConstraints({ make in
            make.left.equalTo(15)
            make.bottom.equalTo(0)
            make.width.equalTo(self.contentView)
            make.height.equalTo(0.5)
        })
        
        self.bottomBorder?.isHidden = true
        
        self.detail = UILabel.init()
        self.contentView.addSubview(self.detail!)
        self.detail?.font = UIFont.systemFont(ofSize: 15)
        self.detail?.textColor = RGB(153, 153, 153)
        self.detail?.snp.makeConstraints({ make in
            make.right.equalTo(self.contentView).offset(-15)
            make.top.equalTo(15)
            make.left.equalTo((self.textLabel?.snp.left)!).offset(100)
            make.height.equalTo(15)
        })
        self.detail?.textAlignment = .right
        
        self.switchIcon = UISwitch.init()
        self.switchIcon?.tintColor = RGB(1, 175, 244)
        
        self.selectedBackgroundView = UIView.init(frame: self.frame)
        self.selectedBackgroundView?.backgroundColor = RGB(244, 245, 246)
    }
    
    func showSwitch() {
        self.contentView.addSubview(self.switchIcon!)
        self.switchIcon?.snp.makeConstraints({ make in
            make.right.equalTo(-15)
            make.top.equalTo(6)
            make.width.equalTo(53)
            make.height.equalTo(30)
        })
        
        self.switchIcon?.addTarget(self, action: #selector(changeNightMode(sender:)), for: .valueChanged)
    }
    
    func opSwitch(status: Bool) {
        self.switchIcon?.isOn = status
    }
    
    func showTopBorder() {
        self.topBorder?.isHidden = false
    }
    
    func showBottomBorder() {
        self.bottomBorder?.isHidden = false
    }
    
    func setDetail(detail: String) {
        self.detail?.text = detail
    }
    
    @objc private func changeNightMode(sender: UISwitch) {
        if self.changeSwitch != nil {
            self.changeSwitch!(sender.isOn)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
