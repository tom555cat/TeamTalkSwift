//
//  UIViewExtension.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/17.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func setWidth(width: CGFloat) {
        var frame = self.frame
        frame.size.width = width
        self.frame = frame
    }
}
