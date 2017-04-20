//
//  UIImageExtension.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/4/13.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

extension UIImage {
    
    class func `init`(withColor color: UIColor, rect: CGRect) -> UIImage {
        let imgRect = CGRect.init(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        UIGraphicsBeginImageContextWithOptions(imgRect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
    
    /*
    class func roundCorners(img: UIImage, corner: Float) -> UIImage {
        var w = img.size.width
        var h = img.size.height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext.init(data: nil, width: Int(w), height: Int(h), bitsPerComponent: 8, bytesPerRow: 4 * Int(w), space: colorSpace, bitmapInfo: 2)
        
        context?.beginPath()
        let rect = CGRect.init(x: 0, y: 0, width: img.size.width, height: img.size.height)
        addRou
    }
    */
}
