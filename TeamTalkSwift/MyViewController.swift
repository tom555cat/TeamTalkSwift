//
//  MyViewController.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/16.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit

class MyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: MTTUserEntity?
    var pushShieldStatus: Bool = false
    
    private var hadUpdate: Int = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = TTBG()
        self.title = "我"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = TTBG()
        
        // 基本信息cell直接设置在了SB中了，无需注册
        self.tableView.register(MTTBaseCell.self, forCellReuseIdentifier: "myFuncIdentifier")
        self.tableView.register(MTTBaseCell.self, forCellReuseIdentifier: "logoutIdentifier")
        self.tableView.register(MTTBaseCell.self, forCellReuseIdentifier: "extraIdentifier")
        
        // 获取夜间模式
        let request = MTTNightModeAPI()
        request.requestWithObject(object: []) { (response: Any?, error: NSError?) in
            if let array = response as? [UInt32] {
                if array[0] == 0 {
                    self.pushShieldStatus = false
                } else {
                    self.pushShieldStatus = true
                }
                self.tableView.reloadData()
            }
        }
        
        /*
         self.hadUpdate=0;
         
         if([TheRuntime.updateInfo[@"haveupdate"] boolValue])
         {
         self.hadUpdate =1;
         }else{
         self.hadUpdate = 0;
         }
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "我"
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableView Delegate & Datasource
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 16))
        headerView.backgroundColor = TTBG()
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section != 0 {
            return 20
        } else {
            return 0.1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 16))
        footerView.backgroundColor = TTBG()
        let detail = UILabel.init(frame: CGRect.init(x: 20, y: 5, width: SCREEN_WIDTH-40, height: 16))
        detail.font = UIFont.systemFont(ofSize: 12)
        detail.textColor = RGB(153, 153, 153)
        if section == 1 {
            detail.text = "开启后,在22:00-8:00时间段收到消息不会有推送."
            footerView.addSubview(detail)
            return footerView
        } else if section == 2 {
            detail.text = ""
            detail.textAlignment = .center
            footerView.addSubview(detail)
            return footerView
        } else {
            return footerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else {
            return 43
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 2 {
            return 1
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let identifier = "myInfoCellIdentifier"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MTTUserInfoCell
            DDUserModule.sharedInstance.getUserFor(userID: (RuntimeStatus.sharedInstance.user?.objID)!, block: { (user: MTTUserEntity?) in
                self.user = user
                cell.setCellContent(avatar: (user?.getAvatarUrl())!, name: (user?.name)!, cname: (user?.nick)!)
            })
            cell.accessoryType = .disclosureIndicator
            return cell
            
        } else if indexPath.section == 1 {
            let identifier = "myFuncIdentifier"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MTTBaseCell
            let row = indexPath.row
            if row == 0 {
                cell.textLabel?.text = "清理缓存"
            } else if row == 1 {
                cell.textLabel?.text = "检查更新"
                //cell.setDetail(detail: String.init(format: "%@", MTTVersion))
                cell.isUserInteractionEnabled = false
                /*
                 if (self.hadUpdate) {
                 [cell setUserInteractionEnabled:YES];
                 [cell showPointBadge:NO];
                 UIView *pointView =[cell pointBadgeView];
                 [pointView mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.left.mas_equalTo(90);
                 make.centerY.equalTo(cell);
                 make.width.mas_equalTo(PointBadgeDiameter);
                 make.height.mas_equalTo(PointBadgeDiameter);
                 }];
                 }
                */
            } else if row == 2 {
                cell.textLabel?.text = "夜间模式"
                cell.isUserInteractionEnabled = true
                cell.showSwitch()
                cell.opSwitch(status: self.pushShieldStatus)
                cell.changeSwitch = { (on: Bool) -> Void in
                    /*
                     MTTChangeNightModeAPI *changeRequest = [MTTChangeNightModeAPI new];
                     NSMutableArray *array = [NSMutableArray new];
                     if(on){
                     [array addObject:@(1)];
                     }else{
                     [array addObject:@(0)];
                     }
                     [changeRequest requestWithObject:array Completion:^(NSArray *response, NSError *error) {
                     _pushShiledStatus = on;
                     }];
                    */
                }
            }
            return cell
            
        } else if indexPath.section == 2 {
            let identifier = "logoutIdentifier"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            cell.textLabel?.text = "退出登录"
            cell.textLabel?.textAlignment = .center
            return cell
            
        } else {
            let identifier = "extraIdentifier"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        if indexPath.section == 0 {
            self.goPersonalProfile()
            
        } else if indexPath.section == 1 {
            tableView.deselectRow(at: indexPath
                , animated: true)
            if indexPath.row == 0 {
                self.clearCacheButtonPressed(sender: nil)
            } else if indexPath.row == 1 {
                self.gotoUpdatePage()
            }
        } else {
            self.logoutButtonPressed(sender: nil)
        }
    }
    
    //MARK: - Private Function
    private func goPersonalProfile() {
        let publicVC = UIStoryboard.init(name: "Contacts", bundle: nil).instantiateViewController(withIdentifier: "PublicProfileVC") as! PublicProfileViewController
        publicVC.user = self.user
        self.navigationController?.pushViewController(publicVC, animated: true)
    }
    
    private func clearCacheButtonPressed(sender: Any?) {
        fatalError("继续实现")
    }
    
    private func gotoUpdatePage() {
        fatalError("继续实现")
    }
    
    private func logoutButtonPressed(sender: Any?) {
        fatalError("继续实现")
    }
}
