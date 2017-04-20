//
//  DDPromptCell.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/3/13.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

class DDPromptCell: UITableViewCell {
    var promptLabel: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.promptLabel = UILabel.init()
        self.promptLabel?.clipsToBounds = true
        self.promptLabel?.font = UIFont.systemFont(ofSize: 11)
        self.promptLabel?.layer.cornerRadius = 5
        self.promptLabel?.textColor = RGB(255, 255, 255)
        self.promptLabel?.backgroundColor = RGBA(100, 100, 100, 0.2)
        self.promptLabel?.textAlignment = .center
        self.contentView.addSubview(self.promptLabel!)
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    func setPrompt(prompt: String) {
        let nsPrompt = NSString.init(string: prompt)
        let size = nsPrompt.boundingRect(with: CGSize.init(width: SCREEN_WIDTH - 30, height: 1000000), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 11)], context: nil)
        self.promptLabel?.snp.remakeConstraints({ make in
            make.centerX.equalTo(self.contentView)
            make.top.equalTo(0)
            make.size.equalTo(CGSize.init(width: size.size.width+30, height: size.size.height+6))
        })
        self.promptLabel?.text = prompt
    }
}
