//
//  RootTabBarController.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2016/12/29.
//  Copyright © 2016年 Hello World Corporation. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 弹出登陆窗口
        //toLoginVC()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private
    
    private func setup()
    {
        let rnc1 = UIStoryboard.init(name: "Recent", bundle: nil).instantiateViewController(withIdentifier: "RecentNC")
        let item1 : UITabBarItem = UITabBarItem(title: "消息", image: UIImage(named: "conversation"), selectedImage: UIImage(named: "conversation_selected"))
        rnc1.tabBarItem = item1
        
        let rnc2 = UIStoryboard.init(name: "Contacts", bundle: nil).instantiateViewController(withIdentifier: "ContactsNC")
        let item2 : UITabBarItem = UITabBarItem(title: "联系人", image: UIImage(named: "contact"), selectedImage: UIImage(named: "contact_selected"))
        rnc2.tabBarItem = item2
        
        let rnc3 = UIStoryboard.init(name: "Find", bundle: nil).instantiateViewController(withIdentifier: "FindNC")
        let item3 : UITabBarItem = UITabBarItem(title: "发现", image: UIImage(named: "tab_nav"), selectedImage: UIImage(named: "tab_nav_selected"))
        rnc3.tabBarItem = item3
        
        let rnc4 = UIStoryboard.init(name: "My", bundle: nil).instantiateViewController(withIdentifier: "MyNC")
        let item4 : UITabBarItem = UITabBarItem(title: "我", image: UIImage(named: "myprofile"), selectedImage: UIImage(named: "myprofile_selected"))
        rnc4.tabBarItem = item4
        
        self.viewControllers = [rnc1, rnc2, rnc3, rnc4]
    }
    
    private func toLoginVC()
    {
        let loginNC = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginNC")
        present(loginNC, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
