//
//  PublicProfileViewController.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/4/18.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit

class PublicProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var user: MTTUserEntity?
    var avatarView: UIImageView?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var cname: UILabel!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!
    
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var footView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.render()
        self.initData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func render() {
        self.title = "详细资料"
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let request = DDUserDetailInfoAPI()
        let userId = self.user?.getOriginalID()
        request.requestWithObject(object: [userId]) { (response: Any?, error: NSError?) in
            if let array = response as? [MTTUserEntity] {
                self.user?.signature = array[0].signature
            }
            self.tableView.reloadData()
        }
        
        // 头像
        self.avatar.clipsToBounds = true
        self.avatar.layer.cornerRadius = 7.5
        
        // 增加图片放大功能
        let placeholder = UIImage.init(withColor: TTBG(), rect: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        self.avatarView = UIImageView.init()
        self.avatarView?.sd_setImage(with: URL.init(string: (self.user?.avatar)!), placeholderImage: placeholder)
        self.avatar.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(showAvatar(recognizer:)))
        self.avatar.addGestureRecognizer(tap)
        
        // 发送消息按钮
        self.chatBtn.clipsToBounds = true
        self.chatBtn.layer.cornerRadius = 5
        
        // 打电话按钮
        self.callBtn.clipsToBounds = true
        self.callBtn.layer.cornerRadius = 5
        
        self.headView.backgroundColor = UIColor.clear
        self.footView.backgroundColor = UIColor.clear
        
    
        if self.user?.objID == RuntimeStatus.sharedInstance.user?.objID {
            self.footView.isHidden = true
        }
    }
    
    private func initData() {
        let placeholder = UIImage.init(named: "user_placeholder")
        self.avatar.sd_setImage(with: URL.init(string: (self.user?.get300AvatarUrl())!), placeholderImage: placeholder)
        self.name.text = self.user?.nick
        self.cname.text = self.user?.name
    }
    
    @objc private func showAvatar(recognizer: UITapGestureRecognizer) {
        fatalError("还需继续实现")
    }
    
    @IBAction func startChat(_ sender: Any) {
        let session = MTTSessionEntity.init(sessionID: (self.user?.objID)!, type: IM_BaseDefine_SessionType.single)
        ChattingMainViewController.sharedInstance.showChattingContent(forSession: session)
        
        if (self.navigationController?.viewControllers.contains(ChattingMainViewController.sharedInstance))! {
            self.navigationController?.popToViewController(ChattingMainViewController.sharedInstance, animated: true)
        } else {
            self.navigationController?.pushViewController(ChattingMainViewController.sharedInstance, animated: true)
        }
    }
    
    @IBAction func callUser(_ sender: Any) {
        fatalError("还需继续实现")
    }
    
    
    
    //MARK: - UITabelViewDelegate & DataSource
    /*
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    */
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.headView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.user?.objID == RuntimeStatus.sharedInstance.user?.objID {
            return 0
        } else {
            return 165
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.footView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 44
        
        if indexPath.row == 2 {
            height = PublicProfileCell.cellHeight(forDetailString: (self.user?.signature)!)
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PublicProfileCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? PublicProfileCell
        if cell == nil {
            cell = PublicProfileCell.init(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        switch indexPath.row {
        case 0:
            cell?.set(desc: "部门", detail: (self.user?.department)!)
            cell?.isUserInteractionEnabled = false
        case 1:
            cell?.set(desc: "邮箱", detail: (self.user?.email)!)
        case 2:
            cell?.set(desc: "签名", detail: (self.user?.signature)!)
            if self.user?.objID != RuntimeStatus.sharedInstance.user?.objID {
                cell?.isUserInteractionEnabled = false
            }
        default:
            break
        }
        
        return cell!
    }
}
