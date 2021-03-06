//
//  NetworkTool.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/1/3.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit

import AFNetworking

enum RequestType {
    case Get
    case Post
}

class NetworkTool: AFHTTPSessionManager {
    static let sharedInstance = NetworkTool()
    
    // 将成功和失败的回调写在一个逃逸闭包中
    func request(requestType : RequestType, url : String, parameters : [String : Any], resultBlock : @escaping([String : Any]?, Error?) -> ()) {
        
        // 成功闭包
        let successBlock = { (task: URLSessionDataTask, responseObj: Any?) in
            resultBlock(responseObj as? [String : Any], nil)
        }
        
        // 失败的闭包
        let failureBlock = { (task: URLSessionDataTask?, error: Error) in
            resultBlock(nil, error)
        }
        
        // Get 请求
        if requestType == .Get {
            get(url, parameters: parameters, progress: nil, success: successBlock, failure: failureBlock)
        }
        
        // Post 请求
        if requestType == .Post {
            post(url, parameters: parameters, progress: nil, success: successBlock, failure: failureBlock)
        }
    }
    
    // 将成功和失败的回调分别写在两个逃逸闭包中
    func request(requestType : RequestType, url : String, parameters : [String : Any], succeed : @escaping([String : Any]?) -> (), failure : @escaping(Error?) -> ()) {
        
        // 成功闭包
        let successBlock = { (task: URLSessionDataTask, responseObj: Any?) in
            succeed(responseObj as? [String : Any])
        }
        
        // 失败的闭包
        let failureBlock = { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
        
        // Get 请求
        if requestType == .Get {
            get(url, parameters: parameters, progress: nil, success: successBlock, failure: failureBlock)
        }
        
        // Post 请求
        if requestType == .Post {
            post(url, parameters: parameters, progress: nil, success: successBlock, failure: failureBlock)
        }
    }
}
