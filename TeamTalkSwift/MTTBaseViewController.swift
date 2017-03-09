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
    
    var viewLifecycleState: MTTViewLifecycleState
    
    func setup() {
    
    }
    
    func pushViewController(viewController: UIViewController, animated: Bool) {
    
    }
    
    func
    
}
