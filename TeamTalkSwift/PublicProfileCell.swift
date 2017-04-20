//
//  PublicProfileCell.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/4/18.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit

class PublicProfileCell: UITableViewCell {

    var descLabel: UILabel?
    var detailLabel: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.descLabel = UILabel.init(frame: CGRect.init(x: 20, y: 15, width: 30, height: 15))
        self.descLabel?.font = UIFont.systemFont(ofSize: 15)
        self.descLabel?.textColor = RGB(164, 165, 169)
        self.contentView.addSubview(self.descLabel!)
        
        self.descLabel?.snp.makeConstraints({ make in
            make.top.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.leading.equalTo(20)
            make.trailing.equalTo(-15)
        })
        
        self.detailLabel = UILabel.init(frame: CGRect.init(x: 70, y: 12, width: SCREEN_WIDTH-85, height: 20))
        self.detailLabel?.numberOfLines = 4
        self.detailLabel?.font = UIFont.systemFont(ofSize: 15)
        self.contentView.addSubview(self.detailLabel!)
        
        self.detailLabel?.snp.makeConstraints({ make in
            make.top.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.leading.equalTo(85)
            make.trailing.equalTo(-15)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    class func cellHeight(forDetailString string: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 15)
        
        let nsstring = NSString.init(string: string)
        let rect = nsstring.boundingRect(with: CGSize.init(width: SCREEN_WIDTH - 100, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        var contentH = rect.size.height + 24
        
        if contentH < 44 {
            contentH = 44
        }
        
        return contentH
    }
    
    func set(desc: String, detail: String) {
        self.descLabel?.text = desc
        self.detailLabel?.text = detail
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
