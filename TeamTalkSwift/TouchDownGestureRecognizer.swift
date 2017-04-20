//
//  TouchDownGestureRecognizer.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/3/16.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

typealias DDTouchDown = () -> Void
typealias DDTouchMoveOutside = () -> Void
typealias DDTouchMoveInside = () -> Void
typealias DDTouchEnd = (Bool) -> Void

let Response_Y: CGFloat = -30

class TouchDownGestureRecognizer: UIGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.touchDown != nil {
            self.touchDown!()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touch = touches.first {
            let point = touch.location(in: self.view)
            print("%f", point.y)
            if point.y < Response_Y {
                if self.inside == true {
                    self.inside = false
                    self.moveOutside!()
                }
            }
            if point.y > Response_Y {
                if self.inside == false {
                    self.inside = true
                    self.moveInside!()
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.touchesEnded(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touch = touches.first {
            let point = touch.location(in: self.view)
            if point.y > Response_Y {
                self.touchEnd!(true)
            } else {
                self.touchEnd!(false)
            }
        }
    }
    
    var touchDown: DDTouchDown?
    var moveOutside: DDTouchMoveOutside?
    var moveInside: DDTouchMoveInside?
    var touchEnd: DDTouchEnd?
    private var inside: Bool?
    
}
