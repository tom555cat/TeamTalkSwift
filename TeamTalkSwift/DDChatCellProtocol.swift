//
//  DDChatCellProtocol.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/26.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

protocol DDChatCellProtocol {
    
    func sizeForContent(content: MTTMessageEntity) -> CGSize
    
    func contentUpGapWithBubble() -> Float
    
    func contentDownGapWithBubble() -> Float
    
    func contentLeftGapWithBubble() -> Float
    
    func contentRightGapWithBubble() -> Float
    
    func layoutContentView(content: MTTMessageEntity)
    
    func cellHeightForMessage(message: MTTMessageEntity) -> Float
}
