//
//  ContactsViewController.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/16.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var searchKey: String?
    var isFromSearch: Bool = false
    var isFromAt: Bool = false
    var selectUser: ((MTTUserEntity) -> Void)?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var model: ContactsModule?
    private var groups = [MTTGroupEntity]()
    private var searchResult: [Any]?
    private var selectIndex: Int = 0
    private var department = [String: [MTTUserEntity]]()
    private var items = [String: [MTTUserEntity]]()
    private var allIndexes = [String]()
    private var departmentIndexes = [String]()
    private var tools: ContactAvatarTools?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "联系人"
        self.model = ContactsModule()
        
        for group in (self.model?.groups)! {
            self.groups.append(group)
        }
        
        self.searchResult = [Any]()
        
        self.segmentedControl.addTarget(self, action: #selector(segmentSelect(sender:)), for: .valueChanged)
        
        self.searchBar.placeholder = "搜索"
        self.searchBar.searchBarStyle = .default
        self.searchBar.barTintColor = TTBG()
        self.searchBar.layer.borderWidth = 0.5
        self.searchBar.layer.borderColor = RGB(204, 204, 204).cgColor
        self.searchBar.delegate = self
        
        self.tableView.tag = 100
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0)
        self.tableView.tableHeaderView = self.searchBar
        self.tableView.separatorStyle = .none
        
        let getFixgroup = DDFixedGroupAPI()
        getFixgroup.requestWithObject(object: nil) { (response: Any?, error: NSError?) in
            if let array = response as? [[String: UInt32]] {
                for dic in array {
                    let groupID = MTTUtil.changeOriginalToLocalID(originalID: dic["groupid"]!, sessionType: IM_BaseDefine_SessionType.group)
                    let version = dic["version"]!
                    let group = DDGroupModule.sharedInstance.getGroup(byGroupID: groupID)
                    if group != nil {
                        if (group?.objectVersion)! == version {
                            self.groups.append(group!)
                        } else {
                            DDGroupModule.sharedInstance.getGroupInfo(groupID: groupID, completion: { (group: MTTGroupEntity) in
                                self.groups.append(group)
                            })
                        }
                        
                    } else {
                        DDGroupModule.sharedInstance.getGroupInfo(groupID: groupID, completion: { (group: MTTGroupEntity) in
                            self.groups.append(group)
                        })
                    }
                }
                
                self.tableView.reloadData()
            }
        }
        
        self.department = (self.model?.sortByDepartment())!
        self.switchContactsToAll()
        
        // 右侧索引颜色透明
        self.tableView.sectionIndexBackgroundColor = UIColor.clear
        self.tableView.sectionIndexColor = RGB(102, 102, 102)
        self.allIndexes = [String]()
        self.departmentIndexes = [String]()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        // 初始化searchTableView
        //[self addSearchTableView];
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "联系人"
        
        if self.searchKey != nil {
            self.segmentedControl.selectedSegmentIndex = 1
            self.selectIndex = 1
            self.switchToShowDepartment()
            
            if self.allIndexes.count > 0 {
                let location = self.allKeys().index(of: self.searchKey!)
                self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: location!), at: .middle, animated: true)
            }
            return
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func switchContactsToAll() {
        self.items = (self.model?.sortByContactPy())!
        self.tableView.reloadData()
    }
    
    func switchToShowDepartment() {
        self.tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc private func appBecomeActive() {
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0)
    }
    
    //MARK: - Action
    @objc private func segmentSelect(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        switch index {
        case 0:
            self.selectIndex = 0
            self.switchContactsToAll()
        case 1:
            self.selectIndex = 1
            self.switchToShowDepartment()
        default:
            break
        }
    }
    
    //MARK: - TableView DataSource
    private func allKeys() -> [String] {
        if self.selectIndex == 1 {
            if self.departmentIndexes.count > 0 {
                return self.departmentIndexes
            } else {
                self.departmentIndexes = Array((self.department.keys))
                self.departmentIndexes.sort(by: { (obj1: String, obj2: String) -> Bool in
                    if obj1 > obj2 {
                        return true
                    } else {
                        return false
                    }
                })
                return self.departmentIndexes
            }
            
        } else {
            if self.allIndexes.count > 0 {
                return self.allIndexes
            } else {
                self.allIndexes = Array((self.items.keys))
                self.allIndexes.sort(by: { (obj1: String, obj2: String) -> Bool in
                    if obj1 > obj2 {
                        return true
                    } else {
                        return false
                    }
                })
                return self.allIndexes
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.selectIndex == 0 {
            return (self.items.keys.count) + 1
        } else {
            return (self.department.keys.count)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectIndex == 0 {
            if section == 0 {
                return self.groups.count
            } else {
                let keyStr = self.allKeys()[section - 1]
                let arr = self.items[keyStr]
                return arr!.count
            }
            
        } else {
            let keyStr = self.allKeys()[section]
            let arr = self.department[keyStr]
            return arr!.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.selectIndex == 0 && section == 0 {
            return 0
        }
        return 22
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var text: String = ""
        if self.selectIndex == 0 {
            if section == 0 {
                text = ""
            } else {
                text = self.allKeys()[section - 1].uppercased()
            }
            
        } else {
            text = self.allKeys()[section].uppercased()
            if text.characters.count == 0 {
                text = "神奇账号"
            }
        }
        
        let sectionHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 22))
        sectionHeaderView.backgroundColor = RGB(240, 240, 245)
        let sectionHeaderLabel = UILabel.init(frame: CGRect.init(x: 10, y: 4.5, width: SCREEN_WIDTH, height: 13))
        sectionHeaderLabel.text = text
        sectionHeaderLabel.textColor = RGB(144, 144, 148)
        sectionHeaderLabel.font = UIFont.systemFont(ofSize: 13)
        sectionHeaderView.addSubview(sectionHeaderLabel)
        return sectionHeaderView
    }
    
    /*
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        var count = 0
        if self.selectIndex == 0 {
            count = 1
        } else {
            count = 0
        }
        for str in self.allKeys() {
            let firstLetter = MTTUtil.getFirstChar(str: str)
            
        }
    }
    */
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ContactsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! DDContactsCell
        if self.selectIndex == 0 {
            if indexPath.section == 0 {
                let group = self.groups[indexPath.row]
                cell.setCellContent(avatar: nil, name: group.name)
                cell.setGroupAvatar(group: group)
                
            } else {
                let keyStr = self.allKeys()[indexPath.section - 1]
                let userArray = self.items[keyStr]
                let user = userArray?[indexPath.row]
                cell.setCellContent(avatar: user?.getAvatarUrl(), name: (user?.nick!)!)
            }
            
        } else {
            let keyStr = self.allKeys()[indexPath.section]
            let userArray = self.department[keyStr]
            let user = userArray?[indexPath.row]
            cell.setCellContent(avatar: user?.getAvatarUrl(), name: (user?.nick)!)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        /*
         if (self.tools.isShow) {
         [self.tools hiddenSelf];
         return;
         }
        */
        
        if self.selectIndex == 0 {
            if indexPath.section == 0 {
                if self.isFromAt {
                    return
                }
                let group = self.groups[indexPath.row]
                let session = MTTSessionEntity.init(sessionID: group.objID!, type: IM_BaseDefine_SessionType.group)
                session.setSessionName(theName: group.name)
                var main = ChattingMainViewController.sharedInstance
                main.showChattingContent(forSession: session)
                self.navigationController?.pushViewController(main, animated: true)
                return
            }
            
            let keyStr = self.allKeys()[indexPath.section - 1]
            let userArray = self.items[keyStr]
            let user = userArray?[indexPath.row]
            
            if self.selectUser != nil && self.isFromAt {
                self.selectUser!(user!)
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            let publicProfileVC = UIStoryboard.init(name: "Contacts", bundle: nil).instantiateViewController(withIdentifier: "PublicProfileVC") as! PublicProfileViewController
            publicProfileVC.user = user
            self.navigationController?.pushViewController(publicProfileVC, animated: true)
            
        } else {
            let keyStr = self.allKeys()[indexPath.section]
            let userArray = self.department[keyStr]
            let user = userArray?[indexPath.row]
            if self.selectUser != nil && self.isFromAt {
                self.selectUser!(user!)
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            let publicProfileVC = UIStoryboard.init(name: "Contacts", bundle: nil).instantiateViewController(withIdentifier: "PublicProfileVC") as! PublicProfileViewController
            publicProfileVC.user = user
            self.navigationController?.pushViewController(publicProfileVC, animated: true)
        }
    }
}
