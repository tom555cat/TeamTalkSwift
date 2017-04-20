//
//  DDSendPhotoMessageAPI.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/4/6.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import Foundation

struct MaxTryUploadTimes {
    static var max_try_upload_times = 5
}

class DDSendPhotoMessageAPI {
    static let sharedPhotoCache = DDSendPhotoMessageAPI()
    private var manager: NetworkTool
    private var queue: OperationQueue?
    private var isSending: Bool = false
    
    init() {
        self.manager = NetworkTool.sharedInstance
        self.manager.responseSerializer.acceptableContentTypes = NSSet.init(object: "text/html") as! Set<String>
        self.queue = OperationQueue.init()
        self.queue?.maxConcurrentOperationCount = 1
    }
    
    func uploadImage(imageKey: String, success: @escaping (String) -> Void, failure: @escaping (Any?) -> Void) {
        let operation = BlockOperation.init {
            let url = URL.init(string: MTTUtil.getMsfsUrl())
            var urlString = url?.absoluteString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            autoreleasepool {
                var imageData = MTTPhotoCache.sharedInstance.photoFromDiskCache(forKey: imageKey)
                if imageData == nil {
                    failure("data is empty")
                    return
                }
                var image = UIImage.init(data: imageData!)
                let imageName = String.init(format: "image.png_%dx%d.png", (image?.size.width)!, (image?.size.height)!)
                let params = ["type": "im_image"]
                self.manager.post(urlString!, parameters: params, constructingBodyWith: { (AFMultipartFormData) in
                    AFMultipartFormData.appendPart(withFileData: imageData!, name: "image", fileName: imageName, mimeType: "image/jpeg")
                }, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
                    imageData = nil
                    image = nil
                    if task.state == .completed {
                        var imageURL: String?
                        if let dic = responseObject as? [String:Any] {
                            if dic["error_code"] as! Int == 0 {
                                imageURL = dic["url"] as! String
                            } else {
                                failure(dic["error_msg"]!)
                            }
                        }
                        
                        var url = DD_MESSAGE_IMAGE_PREFIX
                        if imageURL == nil {
                            MaxTryUploadTimes.max_try_upload_times = MaxTryUploadTimes.max_try_upload_times - 1
                            if MaxTryUploadTimes.max_try_upload_times > 0 {
                                self.uploadImage(imageKey: imageKey, success: { (imageURL: String) in
                                    success(imageURL)
                                }, failure: { (error: Any) in
                                    failure(error)
                                })
                            } else {
                                failure(nil)
                            }
                        }
                        
                        if imageURL != nil {
                            url.append(imageURL!)
                            url.append(":}]&$~@#@")
                            success(url)
                        }
                        
                    } else {
                        self.isSending = false
                        failure(nil)
                    }
                    
                }, failure: { (task: URLSessionDataTask?, error: Error) in
                    self.isSending = false
                    fatalError("还需加入代码")
                })
            }
        }
        
        self.queue?.addOperation(operation)
    }
    
    /*
    class func imageUrl(content: String) -> String {
        let contentStr = NSString.init(string: content)
        let range = contentStr.range(of: "path=")
        var url: NSString?
        if contentStr.length > range.location + range.length {
            url = contentStr.substring(from: range.location + range.length) as NSString?
        }
        url = url?.replacingOccurrences(of: "+", with: " ") as NSString?
        url = url.
    }
     */
}
