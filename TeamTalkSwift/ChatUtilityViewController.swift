//
//  ChatUtilityViewController.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/4/5.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit
import MobileCoreServices

class ChatUtilityViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker: UIImagePickerController?
    var userId: Int = 0
    
    private var itemArray: [Any] = []
    private var rightView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weak var ws = self
        
        self.view.backgroundColor = RGB(244, 244, 246)
        
        let topLine = UIView.init()
        topLine.backgroundColor = UIColor.lightGray
        self.view.addSubview(topLine)
        topLine.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(0.5)
        }
        
        self.imagePicker = UIImagePickerController.init()
        self.imagePicker?.delegate = self
        
        let leftView = UIView.init()
        self.view.addSubview(leftView)
        leftView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.height.equalTo((ws?.view.frame.size.height)!)
            make.top.equalTo(0)
            make.width.equalTo((ws?.view.frame.size.width)! * 0.25)
        }
        
        let takePhotoBtn = UIButton.init(type: .custom)
        self.view.addSubview(takePhotoBtn)
        takePhotoBtn.setBackgroundImage(UIImage.init(named: "chat_take_photo"), for: .normal)
        takePhotoBtn.snp.makeConstraints { make in
            make.centerX.equalTo(leftView)
            make.top.equalTo(15)
            make.size.equalTo(CGSize.init(width: 65, height: 65))
        }
        takePhotoBtn.clipsToBounds = true
        takePhotoBtn.layer.cornerRadius = 5
        takePhotoBtn.layer.borderWidth = 0.5
        takePhotoBtn.layer.borderColor = RGB(174, 177, 181).cgColor
        takePhotoBtn.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
        
        let takePhotoLabel = UILabel.init()
        takePhotoLabel.text = "拍照"
        takePhotoLabel.textAlignment = .center
        takePhotoLabel.font = UIFont.systemFont(ofSize: 13)
        takePhotoLabel.textColor = RGB(174, 177, 181)
        self.view.addSubview(takePhotoLabel)
        takePhotoLabel.snp.makeConstraints { make in
            make.centerX.equalTo(leftView)
            make.top.equalTo(takePhotoBtn.snp.bottom).offset(15)
            make.width.equalTo(leftView)
            make.height.equalTo(13)
        }
        
        let middleView = UIView.init()
        self.view.addSubview(middleView)
        middleView.snp.makeConstraints { make in
            make.left.equalTo(leftView.snp.right)
            make.height.equalTo((ws?.view)!)
            make.top.equalTo((ws?.view)!)
            make.width.equalTo((ws?.view)!).multipliedBy(0.25)
        }
        
        let choosePhotoBtn = UIButton.init(type: .custom)
        self.view.addSubview(choosePhotoBtn)
        choosePhotoBtn.setBackgroundImage(UIImage.init(named: "chat_pick_photo"), for: .normal)
        choosePhotoBtn.snp.makeConstraints { make in
            make.centerX.equalTo(middleView)
            make.top.equalTo(15)
            make.size.equalTo(CGSize.init(width: 65, height: 65))
        }
        choosePhotoBtn.clipsToBounds = true
        choosePhotoBtn.layer.cornerRadius = 5
        choosePhotoBtn.layer.borderWidth = 0.5
        choosePhotoBtn.layer.borderColor = RGB(174, 177, 181).cgColor
        choosePhotoBtn.addTarget(self, action: #selector(choosePicture), for: .touchUpInside)
        
        let choosePhotoLabel = UILabel.init()
        choosePhotoLabel.text = "相册"
        choosePhotoLabel.textAlignment = .center
        choosePhotoLabel.font = UIFont.systemFont(ofSize: 13)
        choosePhotoLabel.textColor = RGB(174, 177, 181)
        self.view.addSubview(choosePhotoLabel)
        choosePhotoLabel.snp.makeConstraints { make in
            make.centerX.equalTo(middleView)
            make.top.equalTo(choosePhotoBtn.snp.bottom).offset(15)
            make.width.equalTo(middleView)
            make.height.equalTo(13)
        }
        
        self.rightView = UIView.init()
        self.view.addSubview(self.rightView!)
        self.rightView?.snp.makeConstraints { make in
            make.left.equalTo(middleView.snp.right)
            make.height.equalTo((ws?.view)!)
            make.top.equalTo((ws?.view)!)
            make.width.equalTo((ws?.view)!).multipliedBy(0.25)
        }
        
        let shakeBtn = UIButton.init(type: .custom)
        rightView?.addSubview(shakeBtn)
        shakeBtn.setBackgroundImage(UIImage.init(named: "chat_shake_pc"), for: .normal)
        shakeBtn.snp.makeConstraints { make in
            make.centerX.equalTo(rightView!)
            make.top.equalTo(15)
            make.size.equalTo(CGSize.init(width: 65, height: 65))
        }
        shakeBtn.clipsToBounds = true
        shakeBtn.layer.cornerRadius = 5
        shakeBtn.layer.borderWidth = 0.5
        shakeBtn.layer.borderColor = RGB(174, 177, 181).cgColor
        shakeBtn.addTarget(self, action: #selector(shakePC), for: .touchUpInside)
        
        let shakeLabel = UILabel.init()
        shakeLabel.text = "抖动"
        shakeLabel.textAlignment = .center
        shakeLabel.font = UIFont.systemFont(ofSize: 13)
        shakeLabel.textColor = RGB(174, 177, 181)
        rightView?.addSubview(shakeLabel)
        shakeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(shakeBtn)
            make.top.equalTo(shakeBtn.snp.bottom).offset(15)
            make.width.equalTo(rightView!)
            make.height.equalTo(13)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Action
    @objc private func takePicture() {
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker?.sourceType = .camera
            }
            self.imagePicker?.modalTransitionStyle = .coverVertical
            if self.imagePicker != nil {
                ChattingMainViewController.sharedInstance.navigationController?.present(self.imagePicker!, animated: false, completion: nil)
            } else {
                self.imagePicker = UIImagePickerController.init()
                self.imagePicker?.delegate = self
                self.imagePicker?.sourceType = .camera
                ChattingMainViewController.sharedInstance.navigationController?.present(self.imagePicker!, animated: false, completion: nil)
            }
        }
    }
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        self.imagePicker = nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        if mediaType == kUTTypeImage as String {
            var theImage: UIImage?
            if picker.allowsEditing {
                theImage = info[UIImagePickerControllerEditedImage] as! UIImage?
            } else {
                theImage = info[UIImagePickerControllerOriginalImage] as! UIImage?
            }
            
            var image = self.scaleImage(image: theImage!, scaleSize: 0.3)
            let imageData = UIImageJPEGRepresentation(image, 1.0)
            var photo = MTTPhotoEntity()
            let keyName = MTTPhotoCache.sharedInstance.getKeyName()
            photo.localPath = keyName
            picker.dismiss(animated: false, completion: nil)
            self.imagePicker = nil
            
            //ChattingMainViewController.sharedInstance.sendIm
            fatalError("ChattingMainViewController还需要发送")
        }
    }
    
    @objc private func choosePicture() {
        //fatalError("还需加入代码")
        let testPhoto = UIImage.init(named: "chatBg.png")
        let photo = MTTPhotoEntity()
        let keyName = MTTPhotoCache.sharedInstance.getKeyName()
        let photoData = UIImagePNGRepresentation(testPhoto!)
        MTTPhotoCache.sharedInstance.storePhoto(photos: photoData!, forKey: keyName, toDisk: true)
        photo.localPath = keyName
        photo.image = testPhoto
        ChattingMainViewController.sharedInstance.sendImageMessage(photo: photo, image: photo.image!)
    }
    
    @objc private func shakePC() {
        fatalError("还需加入代码")
    }
    
    func setShakeHidden() {
        if self.userId != 0 {
            rightView?.isHidden = false
        } else {
            rightView?.isHidden = true
        }
    }

    private func scaleImage(image: UIImage, scaleSize: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize.init(width: image.size.width * scaleSize, height: image.size.height * scaleSize))
        image.draw(in: CGRect.init(x: 0, y: 0, width: image.size.width * scaleSize, height: image.size.height * scaleSize))
        let scaleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaleImage!
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
