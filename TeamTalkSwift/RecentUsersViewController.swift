//
//  RecentUsersViewController.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2016/12/29.
//  Copyright © 2016年 Hello World Corporation. All rights reserved.
//

import UIKit

class RecentUsersViewController: UIViewController, UISearchBarDelegate, SessionModuleDelegate, UITableViewDelegate, UITableViewDataSource {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(n_receiveLoginFailureNotification(notification:)), name: DDNotificationUserLoginFailure, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(n_receiveLoginNotification(notification:)), name: DDNotificationUserLoginSuccess, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name("RefreshRecentData"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(n_receiveReLoginSuccessNotification), name: NSNotification.Name("ReloginSuccess"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: MTTNotificationSessionShieldAndFixed, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(pcLoginNotification(notification:)), name: DDNotificationPCLoginStatusChanged, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "消息"
        self.navigationItem.title = APP_NAME
        
        self.items = [MTTSessionEntity]()
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = TTBG()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchBar.placeholder = "搜索"
        self.searchBar.delegate = self
        self.searchBar.barTintColor = TTBG()
        self.searchBar.layer.borderWidth = 0.5
        self.searchBar.layer.borderColor = UIColor.init(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1).cgColor
        self.tableView.tableHeaderView = self.searchBar
        
        self.lastMsgs = [String: Any]()
        
        
        
        self.items?.append(contentsOf: SessionModule.sharedInstance.getAllSessions())
        self.sortItems()
        
        
        DispatchQueue.global().async {
            SessionModule.sharedInstance.getRecentSession(closure: { (count: Int) in
                self.items?.removeAll()
                self.items?.append(contentsOf: SessionModule.sharedInstance.getAllSessions())
                self.sortItems()
                
                let unreadcount = SessionModule.sharedInstance.getAllUnreadMessageCount()
                
                self.setToolbarBadge(count: unreadcount)
            })
        }
        
        SessionModule.sharedInstance.delegate = self
        
        // 获取mac登陆状态
        self.getMacLoginStatus()
        
        // 初始化searchTableView
        // [self addSearchTableView];
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private Function
    private func sortItems() {
        self.items?.removeAll()
        self.items?.append(contentsOf: SessionModule.sharedInstance.getAllSessions())
        self.items?.sorted { $0.timeInterval < $1.timeInterval }
        self.tableView.reloadData()
    }
    
    @objc private func refreshData() {
        self.setToolbarBadge(count: 0)
        self.sortItems()
    }
    
    private func setToolbarBadge(count: UInt) {
        if count != 0 {
            if count > 99 {
                self.tabBarItem.badgeValue = "99+"
            } else {
                self.tabBarItem.badgeValue = String.init(format: "%ld", count)
            }
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
            self.tabBarItem.badgeValue = nil
        }
    }
    
    private func getMacLoginStatus() {
        let request = MTTUsersStatAPI()
        var array = [Any]()
        let uid = MTTUserEntity.localIDTopb(userid: (RuntimeStatus.sharedInstance.user?.objID)!)
        array.append(uid)
        request.requestWithObject(object: array) { (response: Any?, error: Error?) in
            if let array = response as? [Any] {
                let userList = array[0] as! [Any]
                if IM_BaseDefine_UserStatType.userStatusOnline == (userList[1] as! IM_BaseDefine_UserStatType)  {
                    self.isMacOnline = 1
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func preLoadMessage(_ session: MTTSessionEntity) {
        MTTDatabaseUtil.sharedInstance.getLastestMessageForSession(sessionID: session.sessionID) { (message: MTTMessageEntity?, error: Error?) in
            if message != nil {
                if message?.msgID != session.lastMsgID {
                    DDMessageModule.sharedInstance.getMessageFromServer(fromMsgID: session.lastMsgID, session: session, count: 20, block: { (response: Any, error: NSError?) in
                        if let array = response as? [MTTMessageEntity] {
                            MTTDatabaseUtil.sharedInstance.insertMessage(messageArray: array, success: {
                                // 什么都不做
                            }, failure: { (errorDescription: String) in
                                // 什么都不做
                            })
                        }
                    })
                }
            } else {
                if session.lastMsgID != 0 {
                    DDMessageModule.sharedInstance.getMessageFromServer(fromMsgID: session.lastMsgID, session: session, count: 20, block: { (response: Any, error: NSError?) in
                        if let array = response as? [MTTMessageEntity] {
                            MTTDatabaseUtil.sharedInstance.insertMessage(messageArray: array, success: {
                                // 什么都不做
                            }, failure: { (errorDescription: String) in
                                // 什么都不做
                            })
                        }
                    })
                }
            }
        }
    }
    
    // MARK: - Notification
    func n_receiveLoginFailureNotification(notification: Notification) {
        self.title = "未连接"
    }
    
    func n_receiveStartLoginNotification(notification: Notification) {
        self.title = APP_NAME
    }
    
    func n_receiveLoginNotification(notification: Notification) {
        self.title = APP_NAME
    }
    
    func n_receiveReLoginSuccessNotification() {
        self.title = APP_NAME
        DispatchQueue.global().async {
            SessionModule.sharedInstance.getRecentSession(closure: { (count: Int) in
                self.items?.removeAll()
                self.items?.append(contentsOf: SessionModule.sharedInstance.getAllSessions())
                self.sortItems()
                self.setToolbarBadge(count: UInt(count))
            })
        }
    }
    
    @objc private func pcLoginNotification(notification: Notification) {
        if let dic = notification.object as? [String: Any] {
            if dic["loginStat"] as! Int == IM_BaseDefine_UserStatType.userStatusOffline.rawValue {
                self.isMacOnline = 0
            } else {
                self.isMacOnline = 1
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - SessionModuleDelegate
    func sessionUpdate(session: MTTSessionEntity, withAction action: SessionAction) {
        if (self.items?.contains(where: {$0 === session}))! == false {
            self.items?.insert(session, at: 0)
        }
        self.sortItems()
        self.tableView.reloadData()
        let count = SessionModule.sharedInstance.getAllUnreadMessageCount()
        self.setToolbarBadge(count: count)
    }
    
    // MARK: - UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return (self.items?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0.0
        if indexPath.section == 0 {
            if self.isMacOnline == 1 {
                height = 45
            } else {
                height = 0
            }
        } else {
            height = 72
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellIdentifier = "MTTPCStatusCellIdentifier"
            // 暂时不做在PC登陆的状态栏
            var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            if cell == nil {
                cell = UITableViewCell.init(style: .default, reuseIdentifier: cellIdentifier)
            }
            if self.isMacOnline == 0 {
                cell?.isHidden = true
            }
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentUserCell", for: indexPath) as! RecentUserCell
            let row = indexPath.row
            let view = UIView.init(frame: cell.bounds)
            view.backgroundColor = UIColor.init(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
            let session = self.items?[row]
            if (session?.isFixedTop)! {
                cell.backgroundColor = UIColor.init(red: 243/255.0, green: 243/255.0, blue: 247/255.0, alpha: 1)
            } else {
                cell.backgroundColor = UIColor.white
            }
            view.backgroundColor = UIColor.init(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
            cell.selectedBackgroundView = view
            cell.setShowSession(session: (self.items?[row])!)
            self.preLoadMessage((self.items?[row])!)
            return cell
        }
    }
    
    // MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            // ...
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            let row = indexPath.row
            let session = self.items?[row]
            ChattingMainViewController.sharedInstance.title = session?.name
            ChattingMainViewController.sharedInstance.showChattingContent(forSession: session!)
            
            if self.tabBarController == nil {
                self.navigationController?.pushViewController(ChattingMainViewController.sharedInstance, animated: true)
            } else {
                self.tabBarController?.navigationController?.pushViewController(ChattingMainViewController.sharedInstance, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let session = self.items?[row]
        SessionModule.sharedInstance.removeSessionByServer(session: session!)
        self.items?.remove(at: row)
        self.setToolbarBadge(count: SessionModule.sharedInstance.getAllUnreadMessageCount())
        tableView.deleteRows(at: [indexPath], with: .right)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    var isMacOnline = 0
    
    var lastMsgs: [String: Any]?
    
    var items:[MTTSessionEntity]?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
}
