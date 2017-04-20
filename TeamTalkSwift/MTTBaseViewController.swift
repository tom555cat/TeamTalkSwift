//
//  MTTBaseViewController.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/3/9.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

enum MTTViewLifecycleState: Int {
    case MTTViewLifecycleInit
    case MTTViewLifecycleDidLoad
    case MTTViewLifecycleWillAppear
    case MTTViewLifecycleDidAppear
    case MTTViewLifecycleWillDisAppear
    case MTTViewLifecycleDidDisAppear
}

class MTTBaseViewController: UIViewController {
    
    var viewLifecycleState: MTTViewLifecycleState?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.viewLifecycleState = .MTTViewLifecycleInit
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        self.viewLifecycleState = .MTTViewLifecycleInit
    }
    
    func setup() {
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewLifecycleState = .MTTViewLifecycleDidLoad
        
        let back = UIButton.init(type: .custom)
        back.frame = CGRect.init(x: 0, y: 0, width: 60, height: 40)
        let image = UIImage.init(named: "top_back")
        back.setImage(image, for: .normal)
        back.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 10)
        back.setTitle("返回", for: .normal)
        back.setTitleColor(UIColor.black, for: .normal)
        back.addTarget(self, action: #selector(p_popViewController), for: UIControlEvents.touchUpInside)
        
        let backButton = UIBarButtonItem.init(customView: back)
        self.navigationItem.backBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewLifecycleState = .MTTViewLifecycleWillAppear
        
        if self.tabBarController == nil {
            self.navigationItem.hidesBackButton = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewLifecycleState = .MTTViewLifecycleDidAppear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.viewLifecycleState = .MTTViewLifecycleWillDisAppear
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.viewLifecycleState = .MTTViewLifecycleDidDisAppear
    }
    
    func pushViewController(viewController: UIViewController, animated: Bool) {
        if self.tabBarController == nil {
            self.navigationController?.pushViewController(viewController, animated: animated)
        } else {
            self.tabBarController?.navigationController?.pushViewController(viewController, animated: animated)
        }
    }
    
    func popViewControllerAnimated(animated: Bool) -> UIViewController {
        if self.tabBarController == nil {
            return (self.navigationController?.popViewController(animated: animated))!
        } else {
            return (self.tabBarController?.navigationController?.popViewController(animated: animated))!
        }
    }
    
    func popToViewController(viewController: UIViewController, animated: Bool) -> [UIViewController] {
        if self.tabBarController == nil {
            return (self.navigationController?.popToViewController(viewController, animated: animated))!
        } else {
            return (self.tabBarController?.navigationController?.popToViewController(viewController, animated: animated))!
        }
    }
    
    func p_popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}
