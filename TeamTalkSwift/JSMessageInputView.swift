//
//  JSMessageInputView.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/3/16.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit

enum JSInputBarStyle: Int {
    case defaultStyle
    case flatStyle
}

protocol JSMessageInputViewDelegate {
    func viewHeightChanged(height: CGFloat)
    func textViewEnterSend()
    func textViewChanged()
}


class JSMessageInputView: UIImageView, HPGrowingTextViewDelegate {

    
    var textView: HPGrowingTextView?
    var sendButton: UIButton?
    var showUtilityButton: UIButton?
    var voiceButton: UIButton?
    var recordButton: UIImageView?
    var emotionButton: UIButton?
    var buttonTitle: UILabel?
    
    var delegate: JSMessageInputViewDelegate?
    
    init(frame: CGRect, delegate: JSMessageInputViewDelegate) {
        super.init(frame: frame)
        self.setup()
        self.delegate = delegate
        self.autoresizesSubviews = false
    }
    
    init?(coder aDecoder: NSCoder, delegate: JSMessageInputViewDelegate) {
        super.init(coder: aDecoder)
        self.setup()
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        self.setup()
        self.autoresizesSubviews = false
    }
    
    /*
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        self.setup()
        self.delegate = delegate
    }
    */
    
    private func setup() {
        //self.image = UIImage.inputBar()         仝磊鸣注释掉，没有找到图片
        self.backgroundColor = UIColor.white
        self.isOpaque = true
        self.isUserInteractionEnabled = true
        
        // 分隔线
        let line = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 0.5))
        line.backgroundColor = UIColor.init(red: 188/255.0, green: 188/255.0, blue: 188/255.0, alpha: 1)
        self.addSubview(line)
        
        // 表情键
        self.emotionButton = UIButton.init(frame: CGRect.init(x: SCREEN_WIDTH-36-38, y: 9, width: 28, height: 28))
        self.emotionButton?.setImage(UIImage.init(named: "dd_emotion"), for: .normal)
        self.setSendButton(btn: self.emotionButton!)
        
        // 功能键
        self.showUtilityButton = UIButton.init(frame: CGRect.init(x: SCREEN_WIDTH-38, y: 9, width: 28, height: 28))
        self.showUtilityButton?.setImage(UIImage.init(named: "dd_utility"), for: .normal)
        self.addSubview(self.showUtilityButton!)
        
        // 语音键
        self.voiceButton = UIButton.init(frame: CGRect.init(x: 10, y: 9, width: 28, height: 28))
        self.voiceButton?.setImage(UIImage.init(named: "dd_record_normal"), for: .normal)
        self.voiceButton?.tag = 0
        self.addSubview(self.voiceButton!)
        
        // 创建录音键
        self.setupRecordButton()
        
        // 创建文本
        self.setupTextView()
    }
    
    private func setupTextView() {
        let height = JSMessageInputView.textViewLineHeight()
        
        self.textView = HPGrowingTextView.init(frame: CGRect.init(x: 46, y: 7, width: (self.emotionButton?.frame.origin.x)!-(self.emotionButton?.frame.size.width)!-30, height: height))
        self.textView?.backgroundColor = UIColor.white
        self.textView?.font = UIFont.systemFont(ofSize: 15)
        self.textView?.minHeight = 31
        self.textView?.maxNumberOfLines = 5
        self.textView?.animateHeightChange = true
        self.textView?.animationDuration = 0.25
        self.textView?.delegate = self
        
        self.textView?.layer.borderWidth = 0.5
        self.textView?.layer.borderColor = RGB(188, 188, 188).cgColor
        self.textView?.layer.cornerRadius = 2
        self.textView?.returnKeyType = UIReturnKeyType.send
        self.addSubview(self.textView!)
    }
    
    private func setupRecordButton() {
        let height = JSMessageInputView.textViewLineHeight()
        
        self.recordButton = UIImageView.init(frame: CGRect.init(x: 46, y: 7, width: (self.emotionButton?.frame.origin.x)! - (self.emotionButton?.frame.size.width)! - 30, height: height))
        self.recordButton?.clipsToBounds = true
        self.recordButton?.layer.borderWidth = 1.0
        self.recordButton?.layer.borderColor = RGB(192, 192, 192).cgColor
        self.recordButton?.layer.cornerRadius = 3.0
        self.recordButton?.isUserInteractionEnabled = true
        self.recordButton?.image = self.createImageWithColor(color: RGB(248, 248, 248))
        self.recordButton?.highlightedImage = self.createImageWithColor(color: RGB(230, 230, 230))
        
        self.buttonTitle = UILabel.init(frame: CGRect.init(x: 0, y: 7, width: (self.emotionButton?.frame.origin.x)! - (self.emotionButton?.frame.size.width)! - 30, height: 18))
        self.buttonTitle?.text = "按住说话"
        self.buttonTitle?.textColor = RGB(86, 86, 86)
        self.buttonTitle?.textAlignment = .center
        self.recordButton?.addSubview(self.buttonTitle!)
        self.recordButton?.isOpaque = true
        self.recordButton?.isHidden = true
        self.addSubview(self.recordButton!)
        self.recordButton?.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
    }
    
    private func createImageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect.init(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return theImage!
    }
    
    private func setSendButton(btn: UIButton) {
        if self.sendButton != nil {
            self.sendButton?.removeFromSuperview()
        }
        
        self.sendButton = btn
        self.addSubview(self.sendButton!)
    }
    
    class func inputBarStyle() -> JSInputBarStyle {
        return .defaultStyle
    }
    
    //MARK: HPTextViewDelegate
    func growingTextView(_ growingTextView: HPGrowingTextView!, shouldChangeTextIn range: NSRange, replacementText text: String!) -> Bool {
        if text == "\n" {
            self.delegate?.textViewEnterSend()
            return false
        }
        return true
    }
    
    func growingTextViewDidChange(_ growingTextView: HPGrowingTextView!) {
        self.delegate?.textViewChanged()
    }
    
    func growingTextView(_ growingTextView: HPGrowingTextView!, willChangeHeight height: Float) {
        let bottom = self.bottom()
        if growingTextView.text.characters.count == 0 {
            self.setHeight(height: CGFloat(height) + 13)
        } else {
            self.setHeight(height: CGFloat(height) + 10)
        }
        self.setBottom(bottom: bottom)
        self.delegate?.viewHeightChanged(height: CGFloat(height))
    }
    
    func growingTextViewShouldReturn(_ growingTextView: HPGrowingTextView!) -> Bool {
        return true
    }
    
    //MARK: Message Input View
    
    class func textViewLineHeight() -> CGFloat {
        return 32
    }
    
    class func maxLines() -> CGFloat {
        return 5
    }
    
    class func maxHeight() -> CGFloat {
        return (JSMessageInputView.maxLines() + 1) * (JSMessageInputView.textViewLineHeight())
    }
    
    func willBeginRecord() {
        self.textView?.isHidden = true
        self.recordButton?.isHidden = false
    }
    
    func willBeginInput() {
        self.textView?.isHidden = false
        self.recordButton?.isHidden = true
    }
    
    func setDefaultHeight() {
    
    }
}
