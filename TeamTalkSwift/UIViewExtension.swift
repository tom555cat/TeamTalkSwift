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
    
    func top() -> CGFloat {
        return self.frame.origin.y
    }
    
    func height() -> CGFloat {
        return self.frame.size.height
    }
    
    func setHeight(height: CGFloat) {
        if self.height() == height {
            return
        }
        
        var frame = self.frame
        frame.size.height = height
        self.frame = frame
    }
    
    func bottom() -> CGFloat {
        return self.top() + self.height()
    }
    
    func setBottom(bottom: CGFloat) {
        if self.bottom() == bottom {
            return
        }
        
        var frame = self.frame
        frame.origin.y = bottom - frame.size.height
        self.frame = frame
    }
    
    func setTop(y: CGFloat) {
        var frame = self.frame
        frame.origin.y = y
        self.frame = frame
    }
    
    func subview(withTag tag: Int) -> UIView? {
        for item in self.subviews {
            if item.tag == tag {
                return item
            }
        }
        
        return nil
    }
    
    func centerY() -> CGFloat {
        return self.center.y
    }
    
    func removeAllSubviews() {
        while self.subviews.count > 0 {
            let child = self.subviews.last
            child?.removeFromSuperview()
        }
    }
}
