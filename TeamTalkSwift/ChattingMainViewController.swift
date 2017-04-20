//
//  ChattingMainViewController.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/23.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit

enum DDBottomShowComponent: UInt {
    case DDDefault = 0
    case DDInputViewUp = 1
    case DDShowKeyboard = 2
    case DDShowEmotion = 4
    case DDShowUtility = 8
}

enum DDBottomHiddComponent: UInt {
    case DDInputViewDown = 14
    case DDHideKeyboard = 13
    case DDHideEmotion = 11
    case DDHideUtility = 7
}

enum DDInputType: Int {
    case DDVoiceInput
    case DDTextInput
}

enum PanelStatus: UInt {
    case VoiceStatus
    case TextInputStatus
    case EmotionStatus
    case ImageStatus
}
let CHATINPUTVIEW_HEIGHT: CGFloat = 44
let DDINPUT_TOP_FRAME = CGRect.init(x: 0, y: CONTENT_HEIGHT - CHATINPUTVIEW_HEIGHT + NAVBAR_HEIGHT - 216, width: FULL_WIDTH, height: CHATINPUTVIEW_HEIGHT)
let DDINPUT_BOTTOM_FRAME = CGRect.init(x: 0, y: CONTENT_HEIGHT - CHATINPUTVIEW_HEIGHT + NAVBAR_HEIGHT, width: FULL_WIDTH, height: CHATINPUTVIEW_HEIGHT)
let DDEMOTION_FRAME = CGRect.init(x: 0, y: CONTENT_HEIGHT + NAVBAR_HEIGHT-216, width: FULL_WIDTH, height: 216)
let DDCOMPONENT_BOTTOM = CGRect.init(x: 0, y: CONTENT_HEIGHT + NAVBAR_HEIGHT, width: FULL_WIDTH, height: 216)
let DDUTILITY_FRAME = CGRect.init(x: 0, y: CONTENT_HEIGHT + NAVBAR_HEIGHT - 216, width: FULL_WIDTH, height: 216)

class ChattingMainViewController: MTTBaseViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate, JSMessageInputViewDelegate, DDEmotionsViewControllerDelegate, RecordingDelegate, PlayingDelegate {

    lazy var module: ChattingModule = ChattingModule.init()
    @IBOutlet weak var tableView: UITableView!
    var chatInputView: JSMessageInputView?
    @IBOutlet weak var headerView: UIView!
    var ddUtility: ChatUtilityViewController?
    var emotions: EmotionsViewController?
    var hadLoadHistory: Bool = false
    static let sharedInstance = UIStoryboard.init(name: "Recent", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! ChattingMainViewController
    
    var preShow: UIImageView?
    
    
    //MARK: - Private Property
    private var recordingView: RecordingView?
    private var titleBtn: UIButton?
    private var recordButton: UIButton?
    private var touchDownGestureRecognizer: TouchDownGestureRecognizer?
    private var currentInputContent: String?
    private var bottomShowComponent: DDBottomShowComponent = DDBottomShowComponent.init(rawValue: 0)!
    private var inputViewY: CGFloat = 0 {
        didSet {
            let maxY = FULL_HEIGHT - DDINPUT_MIN_HEIGHT
            let gap = maxY - self.inputViewY
            UIView.animate(withDuration: 0.25, animations: {
                
                self.tableView.contentInset = UIEdgeInsets.init(top: self.tableView.contentInset.top, left: 0, bottom: gap + DDINPUT_MIN_HEIGHT, right: 0)
                
                if (self.bottomShowComponent.rawValue & DDBottomShowComponent.DDShowEmotion.rawValue) != 0 {
                    self.emotions?.view.setTop(y: (self.chatInputView?.bottom())!)
                }
                
                if (self.bottomShowComponent.rawValue & DDBottomShowComponent.DDShowUtility.rawValue) != 0 {
                    // [self.ddUtility.view setTop:self.chatInputView.bottom];
                    self.ddUtility?.view.setTop(y: (self.chatInputView?.bottom())!)
                }
                
            }, completion: { (finished: Bool) in
                // 什么都不做
            })
            
            if gap != 0 {
                self.scrollToBottomAnimated(animated: false)
            }
        }
    }
    
    func sendImageMessage(photo: MTTPhotoEntity, image: UIImage) {
        let messageContentDic = [DD_IMAGE_LOCAL_KEY: photo.localPath!]
        let messageContent = messageContentDic.jsonString()
        
        let message = MTTMessageEntity.makeMessage(content: messageContent!, module: self.module, type: .DDMessageTypeImage)
        self.tableView.reloadData()
        self.scrollToBottomAnimated(animated: true)
        let photoData = UIImagePNGRepresentation(image)
        MTTPhotoCache.sharedInstance.storePhoto(photos: photoData!, forKey: photo.localPath!, toDisk: true)
        MTTDatabaseUtil.sharedInstance.insertMessage(messageArray: [message], success: {
            DDLog("消息插入DB成功")
        }) { (String) in
            DDLog("消息插入DB失败")
        }
        DDSendPhotoMessageAPI.sharedPhotoCache.uploadImage(imageKey: messageContentDic[DD_IMAGE_LOCAL_KEY]!, success: { (imageURL: String) in
            self.scrollToBottomAnimated(animated: true)
            message.state = .DDMessageSending
            var tempMessageContent = MTTUtil.jsonStringToDictionary(text: message.msgContent)
            tempMessageContent?[DD_IMAGE_URL_KEY] = imageURL
            let messageContent = tempMessageContent?.jsonString()
            message.msgContent = messageContent!
            self.sendMessage(msg: imageURL, messageEntity: message)
            MTTDatabaseUtil.sharedInstance.updateMessage(message: message, completion: { (result: Bool) in
                // 什么都不做
            })
        }) { (error: Any?) in
            message.state = .DDMessageSendFailure
            MTTDatabaseUtil.sharedInstance.updateMessage(message: message, completion: { (result: Bool) in
                if result {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.titleBtn = UIButton.init(type: .custom)
        self.titleBtn?.frame = CGRect.init(x: 0, y: 0, width: 150, height: 40)
        self.titleBtn?.addTarget(self, action: #selector(titleTap), for: UIControlEvents.touchUpInside)
        self.titleBtn?.titleLabel?.textAlignment = .left
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.notificationCenter()
        self.initialInput()
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(p_tapOnTableView(recognizer:)))
        pan.delegate = self
        self.tableView.addGestureRecognizer(pan)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = UIColor.clear
        
        // tableView添加headerView以后再做
        
        self.scrollToBottomAnimated(animated: false)
        
        self.initScrollView()
        
        let item = UIBarButtonItem.init(image: UIImage.init(named: "myprofile"), style: .plain, target: self, action: #selector(Edit(sender:)))
        self.navigationItem.rightBarButtonItem = item
        
        /*
         [self.module addObserver:self
         forKeyPath:@"showingMessages"
         options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
         context:NULL];
         [self.module addObserver:self
         forKeyPath:@"MTTSessionEntity.sessionID"
         options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
         context:NULL];
        */
        
        self.navigationItem.titleView?.isUserInteractionEnabled = true
        self.view.backgroundColor = TTBG()
        
        /*
         if([TheRuntime.user.nick isEqualToString:@"蝎紫"]){
         UIImageView *chatBgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
         [chatBgView setImage:[UIImage imageNamed:@"chatBg"]];
         [self.view insertSubview:chatBgView atIndex:0];
         self.tableView.backgroundView =chatBgView;
         }
        */
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        /*
         self.isGotoAt = NO;
         self.ifScrollBottom = YES;
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true      // 仝磊鸣
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // [self.chatInputView.textView setEditable:YES];
        
        self.navigationController?.navigationBar.isHidden = false
        
        self.tabBarController?.tabBar.isHidden = true      // 仝磊鸣
        
        /*
         if (self.ddUtility != nil)
         {
         NSString *sessionId = self.module.MTTSessionEntity.sessionID;
         self.ddUtility.userId = [MTTUserEntity localIDTopb:sessionId];
         }
        */
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.module.ids.removeAll()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        /*
         if(!self.isGotoAt){
         [super viewDidDisappear:animated];
         [self.chatInputView.textView setEditable:NO];
         }
        */
    }
    
    func showChattingContent(forSession session: MTTSessionEntity) {
        self.module.MTTSessionEntity = nil
        self.hadLoadHistory = false
        self.p_unableChatFunction()
        self.p_enableChatFunction()
        self.module.showingMessages.removeAll()
        if self.tableView != nil {
            self.tableView.reloadData()
        }
        self.module.MTTSessionEntity = session
        self.setThisViewTitle(title: session.name)
        self.module.loadMoreHistory { (addCount: UInt32, error: NSError?) in
            if self.tableView != nil {
                self.tableView.reloadData()
            }
            
            if self.hadLoadHistory == false {
                self.scrollToBottomAnimated(animated: false)
            }
            
            if session.unReadMsgCount != 0 {
                let readACK = MsgReadACKAPI()
                if self.module.MTTSessionEntity?.sessionID != nil {
                    readACK.requestWithObject(object: [self.module.MTTSessionEntity?.sessionID, self.module.MTTSessionEntity?.lastMsgID, self.module.MTTSessionEntity?.sessionType.rawValue], completion: { (response: Any?, error: Error?) in
                        // 什么都不做
                    })
                    MTTDatabaseUtil.sharedInstance.updateRecentSession(session: self.module.MTTSessionEntity!, completion: { (error: NSError?) in
                        // 什么都不做
                    })
                }
            }
        }
    }
    
    func p_unableChatFunction() {
    
    }
    
    func p_enableChatFunction() {
    
    }
    
    func setThisViewTitle(title: String) {
        self.titleBtn?.titleLabel?.text = title
        self.queryUserStat()
    }
    
    func queryUserStat() {
        let request = MTTUsersStatAPI()
        let sessionId = self.module.MTTSessionEntity?.sessionID
        let uid = MTTUserEntity.localIDTopb(userid: sessionId!)
        request.requestWithObject(object: [uid]) { (response: Any?, error: Error?) in
            // 什么都不做
        }
    }
    
    func scrollToBottomAnimated(animated: Bool) {
        let rows = self.tableView.numberOfRows(inSection: 0)
        if rows > 0 {
            self.tableView.scrollToRow(at: IndexPath.init(row: rows - 1, section: 0), at: .bottom, animated: animated)
        }
    }
    
    func initialInput() {
        let inputFrame = CGRect.init(x: 0, y: CONTENT_HEIGHT - DDINPUT_MIN_HEIGHT + NAVBAR_HEIGHT, width: FULL_WIDTH, height: DDINPUT_MIN_HEIGHT)
        self.chatInputView = JSMessageInputView.init(frame: inputFrame, delegate: self)
        self.chatInputView?.backgroundColor = RGBA(249, 249, 249, 0.9)
        self.view.addSubview(self.chatInputView!)
        
        self.chatInputView?.emotionButton?.addTarget(self, action: #selector(showEmotions(sender:)), for: .touchUpInside)
        self.chatInputView?.showUtilityButton?.addTarget(self, action: #selector(showUtilitys(sender:)), for: .touchDown)
        self.chatInputView?.voiceButton?.addTarget(self, action: #selector(p_clickThRecordButton(button:)), for: .touchUpInside)
        
        self.touchDownGestureRecognizer = TouchDownGestureRecognizer.init(target: self, action: nil)
        weak var weakSelf = self
        self.touchDownGestureRecognizer?.touchDown = {
            weakSelf?.p_record(button: nil)
        }
        
        self.touchDownGestureRecognizer?.moveInside = {
            weakSelf?.p_endCancelRecord(button: nil)
        }
        
        self.touchDownGestureRecognizer?.moveOutside = {
            weakSelf?.p_willCancelRecord(button: nil)
        }
        
        self.touchDownGestureRecognizer?.touchEnd = { (inside: Bool) in
            if inside {
                weakSelf?.p_sendRecord(button: nil)
            } else {
                weakSelf?.p_cancelRecord(button: nil)
            }
        }
        
        self.chatInputView?.recordButton?.addGestureRecognizer(self.touchDownGestureRecognizer!)
        self.recordingView = RecordingView.init(state: .DDShowVolumnState)
        self.recordingView?.isHidden = true
        self.recordingView?.center = CGPoint.init(x: FULL_WIDTH/2, y: self.view.centerY())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - RecordingDelegate
    func recordingFinished(withFileName filePath: String!, time interval: TimeInterval) {
        var muData = Data.init()
        weak var weakSelf = self
        do {
            let data = try Data.init(contentsOf: URL.init(fileURLWithPath: filePath))
            let length: Int32 = Int32(RecorderManager.shared().recordedTimeInterval())
            if length < 1 {
                DDLog("录音时间太短")
                DispatchQueue.main.async {
                    weakSelf?.recordingView?.isHidden = false
                    weakSelf?.recordingView?.setRecordingState(recordingState: .DDShowRecordTimeTooShort)
                }
                return
                
            } else {
                DispatchQueue.main.async {
                    weakSelf?.recordingView?.isHidden = true
                }
            }
            
            // 转换字节顺序
            var ch = [UInt8]()
            for i in 0..<4 {
                ch.append( UInt8((length >> ((3 - i) * 8)) & 0x0ff) )
            }
            muData.append(ch, count: 4)         // 写入长度
            muData.append(data)                 // 写入文件内容
            
            let msgContentType = DDMessageContentType.DDMessageTypeVoice
            let message = MTTMessageEntity.makeMessage(content: filePath, module: self.module, type: msgContentType)
            self.tableView.reloadData()
            self.scrollToBottomAnimated(animated: true)
            let isGroup = (self.module.MTTSessionEntity?.isGroup())!
            if isGroup {
                message.msgType = .groupAudio
            } else {
                message.msgType = .singleAudio
            }
            message.info?[VOICE_LENGTH] = length
            message.info?[DDVOICE_PLAYED] = 1
            DispatchQueue.main.async {
                weakSelf?.scrollToBottomAnimated(animated: true)
                MTTDatabaseUtil.sharedInstance.insertMessage(messageArray: [message], success: {
                    DDLog("消息插入DB成功")
                }, failure: { (errorDescription: String) in
                    DDLog("消息插入DB失败")
                })
            }
            
            DDMessageSendManager.sharedInstance.sendVoiceMessage(voice: muData, filePath: filePath, forSessionID: (self.module.MTTSessionEntity?.sessionID)!, isGroup: isGroup, msg: message, session: self.module.MTTSessionEntity!, completion: { (theMessage: MTTMessageEntity?, error: NSError?) in
                if error == nil {
                    DDLog("发送语音消息成功")
                    PlayerManager.shared().playAudio(withFileName: "msg.caf", playerType: .DDSpeaker, delegate: self)
                    message.state = .DDMessageSendSuccess
                    MTTDatabaseUtil.sharedInstance.updateMessage(message: message, completion: { (result: Bool) in
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    })
                    
                } else {
                    DDLog("发送语音消息失败")
                    message.state = .DDMessageSendFailure
                    MTTDatabaseUtil.sharedInstance.updateMessage(message: message, completion: { (result: Bool) in
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    })
                }
                
            })
            
        } catch {
            DDLog("读取语音文件出错")
        }
        
    }
    
    //MARK: - PlayingDelegate
    func playingStoped() {
        
    }
    
    //MARK: - Action
    
    func Edit(sender: Any) {
    
    }
    
    func initScrollView() {
        weak var weakSelf = self
        //self.tableView.refre
    }
    
    func p_tapOnTableView(recognizer: UIPanGestureRecognizer) {
        self.removeImage()
        if self.bottomShowComponent != nil {
            self.p_hideBottomComponent()
        }
    }
    
    private func p_hideBottomComponent() {
        self.bottomShowComponent = DDBottomShowComponent.init(rawValue: (self.bottomShowComponent.rawValue) & 0)!
        self.chatInputView?.textView?.resignFirstResponder()
        UIView.animate(withDuration: 0.25) {
            self.ddUtility?.view.frame = DDCOMPONENT_BOTTOM
            self.emotions?.view.frame = DDCOMPONENT_BOTTOM
            self.chatInputView?.frame = DDINPUT_BOTTOM_FRAME
        }
        
        self.inputViewY = (self.chatInputView?.frame.origin.y)!
        self.view.endEditing(true)
    }
    
    private func removeImage() {
        /*
         _lastPhoto = nil;
         [_preShow removeFromSuperview];
        */
    }
    
    func p_record(button: UIButton?) {
        self.chatInputView?.recordButton?.isHighlighted = true
        self.chatInputView?.buttonTitle?.text = "松开发送"
        if !self.view.subviews.contains(self.recordingView!) {
            self.view.addSubview(self.recordingView!)
        }
        self.recordingView?.isHidden = false
        self.recordingView?.setRecordingState(recordingState: .DDShowVolumnState)
        
        RecorderManager.shared().delegate = self
        RecorderManager.shared().startRecording()
        DDLog("record")
    }
    
    func p_endCancelRecord(button: UIButton?) {
        self.recordingView?.isHidden = false
        self.recordingView?.setRecordingState(recordingState: .DDShowVolumnState)
    }
    
    func p_willCancelRecord(button: UIButton?) {
        self.recordingView?.isHidden = false
        self.recordingView?.setRecordingState(recordingState: .DDShowCancelSendState)
        DDLog("will cancel record")
    }
    
    func p_sendRecord(button: UIButton?) {
        self.chatInputView?.recordButton?.isHighlighted = false
        self.chatInputView?.buttonTitle?.text = "按住说话"
        RecorderManager.shared().stopRecording()
        DDLog("send record")
    }
    
    func p_cancelRecord(button: UIButton?) {
        self.chatInputView?.recordButton?.isHighlighted = false
        self.chatInputView?.buttonTitle?.text = "按住说话"
        self.recordingView?.isHidden = true
        RecorderManager.shared().cancelRecording()
        DDLog("cancel record")
    }
    
    func showEmotions(sender: Any) {
        /*
         [_recordButton setImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];
         _recordButton.tag = DDVoiceInput;
        */
        self.chatInputView?.willBeginInput()
        /*
        if (self.currentInputContent?.characters.count)! > 0 {
            self.chatInputView.textView?.text = self.currentInputContent
        }
        */
        
        if self.emotions == nil {
            self.emotions = EmotionsViewController()
            self.emotions?.view.backgroundColor = UIColor.white
            self.emotions?.view.frame = DDCOMPONENT_BOTTOM
            self.emotions?.delegate = self
            self.view.addSubview((self.emotions?.view)!)
        }
        
        if (self.bottomShowComponent.rawValue & DDBottomShowComponent.DDShowKeyboard.rawValue) != 0 {
            // 显示的是键盘，需要隐藏键盘，显示表情，不需要动画
            self.bottomShowComponent = DDBottomShowComponent.init(rawValue: ((self.bottomShowComponent.rawValue & 0) | DDBottomShowComponent.DDShowEmotion.rawValue))!
            self.chatInputView?.textView?.resignFirstResponder()
            self.emotions?.view.frame = DDEMOTION_FRAME
            // [self.ddUtility.view setFrame:DDCOMPONENT_BOTTOM];
        } else if (self.bottomShowComponent.rawValue & DDBottomShowComponent.DDShowEmotion.rawValue) != 0 {
            // 表情面板本来就是显示的，这时需要隐藏所有底部界面
            self.chatInputView?.textView?.resignFirstResponder()
            self.bottomShowComponent = DDBottomShowComponent.init(rawValue: self.bottomShowComponent.rawValue & DDBottomHiddComponent.DDHideEmotion.rawValue)!
        } else if (self.bottomShowComponent.rawValue & DDBottomShowComponent.DDShowUtility.rawValue) != 0 {
            // 显示的是插件，这时需要隐藏插件，显示表情
            // [self.ddUtility.view setFrame:DDCOMPONENT_BOTTOM];
            self.emotions?.view.frame = DDEMOTION_FRAME
            self.bottomShowComponent = DDBottomShowComponent.init(rawValue: ((self.bottomShowComponent.rawValue & DDBottomHiddComponent.DDHideUtility.rawValue) | DDBottomShowComponent.DDShowEmotion.rawValue))!
        } else {
            // 这是什么都没有显示，需用动画显示表情
            self.bottomShowComponent = DDBottomShowComponent.init(rawValue: self.bottomShowComponent.rawValue | DDBottomShowComponent.DDShowEmotion.rawValue)!
            UIView.animate(withDuration: 0.25, animations: {
                self.emotions?.view.frame = DDEMOTION_FRAME
                self.chatInputView?.frame = DDINPUT_TOP_FRAME
            })
            self.inputViewY = DDINPUT_TOP_FRAME.origin.y
        }
    }
    
    func showUtilitys(sender: Any) {
        self.recordButton?.setImage(UIImage.init(named: "dd_record_normal"), for: .normal)
        self.recordButton?.tag = Int(DDInputType.DDVoiceInput.rawValue)
        self.chatInputView?.willBeginInput()
        
        /*
        if (currentInputContent?.characters.count)! > 0 {
            self.chatInputView.textView?.text = currentInputContent
        }
         */
        
        if self.ddUtility == nil {
            self.ddUtility = ChatUtilityViewController()
            let sessionId = self.module.MTTSessionEntity?.sessionID
            if self.module.isGroup != 0 {
                self.ddUtility?.userId = 0
            } else {
                self.ddUtility?.userId = Int(MTTUserEntity.localIDTopb(userid: sessionId!))
            }
            self.addChildViewController(self.ddUtility!)
            self.ddUtility?.view.frame = CGRect.init(x: 0, y: self.view.frame.size.height, width: FULL_WIDTH, height: 280)
            self.view.addSubview((self.ddUtility?.view)!)
        }
        self.ddUtility?.setShakeHidden()
        
        if (bottomShowComponent.rawValue & DDBottomShowComponent.DDShowKeyboard.rawValue) != 0 {
            // 显示的是键盘，这时需要隐藏键盘，显示插件，不需要动画
            bottomShowComponent = DDBottomShowComponent.DDShowUtility
            self.chatInputView?.textView?.resignFirstResponder()
            self.ddUtility?.view.frame = DDUTILITY_FRAME
            self.emotions?.view.frame = DDCOMPONENT_BOTTOM
        } else if (bottomShowComponent.rawValue & DDBottomShowComponent.DDShowUtility.rawValue) != 0 {
            // 插件面板本来就是显示的，这时需要隐藏所有底部界面
            self.chatInputView?.textView?.becomeFirstResponder()
            bottomShowComponent = DDBottomShowComponent.init(rawValue: bottomShowComponent.rawValue & DDBottomHiddComponent.DDHideUtility.rawValue)!
        } else if (bottomShowComponent.rawValue & DDBottomShowComponent.DDShowEmotion.rawValue) != 0 {
            // 显示的是表情，这时需要隐藏表情，显示插件
            self.emotions?.view.frame = DDCOMPONENT_BOTTOM
            self.ddUtility?.view.frame = DDUTILITY_FRAME
            self.bottomShowComponent = DDBottomShowComponent.init(rawValue: (bottomShowComponent.rawValue & DDBottomHiddComponent.DDHideEmotion.rawValue) | DDBottomShowComponent.DDShowUtility.rawValue)!
        } else {
            // 这时什么都没有显示，需用动画显示插件
            self.bottomShowComponent = DDBottomShowComponent.init(rawValue: self.bottomShowComponent.rawValue | DDBottomShowComponent.DDShowUtility.rawValue)!
            UIView.animate(withDuration: 0.25, animations: {
                self.ddUtility?.view.frame = DDUTILITY_FRAME
                self.chatInputView?.frame = DDINPUT_TOP_FRAME
            })
            self.inputViewY = DDINPUT_TOP_FRAME.origin.y
        }
        
        // 判断最后一张照片是不是90s内
        // 还需要添加
    }
    
    func p_clickThRecordButton(button: UIButton) {
        switch button.tag {
        case DDInputType.DDVoiceInput.rawValue:
            // 开始录音
            self.p_hideBottomComponent()
            button.setImage(UIImage.init(named: "dd_input_normal"), for: .normal)
            button.tag = DDInputType.DDTextInput.rawValue
            self.chatInputView?.willBeginRecord()
            self.chatInputView?.textView?.resignFirstResponder()
            self.currentInputContent = self.chatInputView?.textView?.text
            if (self.currentInputContent?.characters.count)! > 0 {
                self.chatInputView?.textView?.text = nil
            }
            
        case DDInputType.DDTextInput.rawValue:
            // 开始输入文字
            button.setImage(UIImage.init(named: "dd_record_normal"), for: .normal)
            button.tag = DDInputType.DDVoiceInput.rawValue
            self.chatInputView?.willBeginInput()
            if (self.currentInputContent?.characters.count)! > 0 {
                self.chatInputView?.textView?.text = self.currentInputContent
            }
            self.chatInputView?.textView?.becomeFirstResponder()
            
        default:
            break
        }
    }
    
    
    func titleTap() {
        /*
         if ([self.module.MTTSessionEntity isGroup]) {
         return;
         }
         [self.module getCurrentUser:^(MTTUserEntity *user) {
         PublicProfileViewControll *profile = [PublicProfileViewControll new];
         profile.title=user.nick;
         profile.user=user;
         [self pushViewController:profile animated:YES];
         }];
         */
    }
    
    //MARK: - UIGestureDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == self.tableView {
            return true
        } else {
            return false
        }
    }
    
    //MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "MTTSessionEntity.sessionID" {
            if change?[.newKey] != nil {
                self.setThisViewTitle(title: (self.module.MTTSessionEntity?.name)!)
            }
        }
        
        if keyPath == "inputViewY" {
            let maxY = FULL_HEIGHT - DDINPUT_MIN_HEIGHT
            let gap = maxY - self.inputViewY
            UIView.animate(withDuration: 0.25, animations: {
                
                self.tableView.contentInset = UIEdgeInsets.init(top: self.tableView.contentInset.top, left: 0, bottom: gap + DDINPUT_MIN_HEIGHT, right: 0)
                
                if ((self.bottomShowComponent.rawValue) & DDBottomShowComponent.DDShowEmotion.rawValue) != 0 {
                    // [self.emotions.view setTop:self.chatInputView.bottom];
                }
                
                if ((self.bottomShowComponent.rawValue) & DDBottomShowComponent.DDShowUtility.rawValue) != 0 {
                    // [self.ddUtility.view setTop:self.chatInputView.bottom];
                }
                
            }, completion: { (finished: Bool) in
                // 什么都不做
            })
            
            if gap != 0 {
                self.scrollToBottomAnimated(animated: false)
            }
        }
    }
    
    //MARK: - UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("contentSize height is: \(self.tableView.contentSize.height)")
        return self.module.showingMessages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        let object = self.module.showingMessages[indexPath.row]
        if let message = object as? MTTMessageEntity {
            height = CGFloat(self.module.messageHeight(message: message))
        } else if object is DDPromptEntity {
            height = 30
        }
        return height + 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = self.module.showingMessages[indexPath.row]
        var cell: UITableViewCell? = nil
        if let message = object as? MTTMessageEntity {
            if message.msgContentType == .DDMessageTypeText {
                
                cell = self.p_textCell(tableView: tableView, cellForRowAtIndexPath: indexPath, message: message)
                
            } else if message.msgContentType == .DDMessageTypeVoice {
                
                cell = self.p_voiceCell(tableView: tableView, cellForRowAtIndexPath: indexPath, message: message)
                
            } else if message.msgContentType == .DDMessageTypeImage {
            
                cell = self.p_imageCell(tableView: tableView, cellForRowAtIndexPath: indexPath, message: message)
                
            } else if message.msgContentType == .DDMessageEmotion {
            
                cell = self.p_emotionCell(tableView: tableView, cellForRowAtIndexPath: indexPath, message: message)
                
            } else {
                
                cell = self.p_textCell(tableView: tableView, cellForRowAtIndexPath: indexPath, message: message)
            
            }
            
        } else if let prompt = object as? DDPromptEntity {
            
            cell = self.p_promptCell(tableView: tableView, cellForRowAtIndexPath: indexPath, prompt: prompt)
            
        }
        return cell!
    }
    
    //MARK: - EmojiFace Function
    func insertEmojiFace(string: String) {
        let message = MTTMessageEntity.makeMessage(content: string, module: self.module, type: .DDMessageEmotion)
        self.tableView.reloadData()
        MTTDatabaseUtil.sharedInstance.insertMessage(messageArray: [message], success: {
            DDLog("消息插入DB成功")
        }) { (errorDescription: String) in
            DDLog("消息插入DB失败")
        }
        self.sendMessage(msg: string, messageEntity: message)
    }
    
    func deleteEmojiFace() {
        var toDeleteString: String = ""
        if self.chatInputView?.textView?.text.characters.count == 0 {
            return
        }
        if self.chatInputView?.textView?.text.characters.count == 1 {
            self.chatInputView?.textView?.text = ""
        } else {
            var index = self.chatInputView?.textView?.text.index((self.chatInputView?.textView?.text.startIndex)!, offsetBy: (self.chatInputView?.textView?.text.characters.count)! - 1)
            toDeleteString = (self.chatInputView?.textView?.text.substring(from: index!))!
            var length = EmotionsModule.sharedInstance.emotionLength?[toDeleteString] as! Int
            if length == 0 {
                index = self.chatInputView?.textView?.text.index((self.chatInputView?.textView?.text.startIndex)!, offsetBy: (self.chatInputView?.textView?.text.characters.count)! - 2)
                toDeleteString = (self.chatInputView?.textView?.text.substring(from: index!))!
                length = EmotionsModule.sharedInstance.emotionLength?[toDeleteString] as! Int
            }
            length = length == 0 ? 1 : length
            index = self.chatInputView?.textView?.text.index((self.chatInputView?.textView?.text.startIndex)!, offsetBy: (self.chatInputView?.textView?.text.characters.count)! - length)
            self.chatInputView?.textView?.text = self.chatInputView?.textView?.text.substring(to: index!)
        }
    }
    
    //MARK: - DDEmotionViewControllerDelegate
    func emotionViewClickSendButton() {
        self.textViewEnterSend()
    }
    
    
    //MARK: - ScrollView Delegate
    
    
    //MARK: - Private API
    
    func p_textCell(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, message: MTTMessageEntity) -> UITableViewCell {
        let identifier = "DDChatTextCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DDChatTextCell
        if cell == nil {
            cell = DDChatTextCell.init(style: .default, reuseIdentifier: identifier)
            cell?.contentLabel?.delegate = self
        }
        cell?.session = self.module.MTTSessionEntity
        let myUserID = RuntimeStatus.sharedInstance.user?.objID
        if message.senderId == myUserID {
            cell?.location = .DDBubbleRight
        } else {
            cell?.location = .DDBubbleLeft
        }
        
        if !UnAckMessageManager.sharedInstance.isInUnAckQueue(message: message) && message.state == .DDMessageSending && message.isSendBySelf() {
            message.state = .DDMessageSendFailure
        }
        
        // 什么情况下需要修改本地消息???????
        MTTDatabaseUtil.sharedInstance.updateMessage(message: message) { (result: Bool) in
            // 什么都不做
        }
        
        cell?.setContent(content: message)
        weak var weakCell = cell
        cell?.sendAgain = {
            weakCell?.showSending()
            weakCell?.sendTextAgain(message: message)
        }
        
        return cell!
    }
    
    func p_voiceCell(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, message: MTTMessageEntity) -> UITableViewCell {
        let identifier = "DDVoiceCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DDChatVoiceCell
        
        if cell == nil {
            cell = DDChatVoiceCell.init(style: .default, reuseIdentifier: identifier)
        }
        cell?.session = self.module.MTTSessionEntity
        let myUserID = RuntimeStatus.sharedInstance.user?.objID
        if message.senderId == myUserID {
            cell?.location = .DDBubbleRight
        } else {
            cell?.location = .DDBubbleLeft
        }
        cell?.setContent(content: message)
        
        weak var weakCell = cell
        cell?.tapInBubble = {
            // 播放语音
            // 需要PlayerManager
        }
        
        return cell!
    }
    

    func p_promptCell(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, prompt: DDPromptEntity) -> UITableViewCell {
        let identifier = "DDPromptCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DDPromptCell
        if cell == nil {
            cell = DDPromptCell.init(style: .default, reuseIdentifier: identifier)
        }
        cell?.setPrompt(prompt: prompt.message!)
        
        return cell!
    }
    
    func p_emotionCell(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, message: MTTMessageEntity) -> UITableViewCell {
        let identifier = "DDEmotionCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DDEmotionCell
        if cell == nil {
            cell = DDEmotionCell.init(style: .default, reuseIdentifier: identifier)
        }
        cell?.session = self.module.MTTSessionEntity
        let myUserID = RuntimeStatus.sharedInstance.user?.objID
        if message.senderId == myUserID {
            cell?.location = .DDBubbleRight
        } else {
            cell?.location = .DDBubbleLeft
        }
        
        cell?.setContent(content: message)
        weak var weakCell = cell
        
        cell?.sendAgain = {
            weakCell?.sendTextAgain(message: message)
        }
        
        cell?.tapInBubble = {
        
        }
        
        return cell!
    }
    
    func p_imageCell(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, message: MTTMessageEntity) -> UITableViewCell {
        let identifier = "DDImageCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DDChatImageCell
        if cell == nil {
            cell = DDChatImageCell.init(style: .default, reuseIdentifier: identifier)
        }
        cell?.session = self.module.MTTSessionEntity
        let myUserID = RuntimeStatus.sharedInstance.user?.objID
        if message.senderId == myUserID {
            cell?.location = .DDBubbleRight
        } else {
            cell?.location = .DDBubbleLeft
        }
        
        MTTDatabaseUtil.sharedInstance.updateMessage(message: message) { (result: Bool) in
            // 什么都不做
        }
        cell?.setContent(content: message)
        
        cell?.tapInBubble = {
            var originUrl = message.msgContent
            originUrl = originUrl.replacingOccurrences(of: DD_MESSAGE_IMAGE_PREFIX, with: "")
            originUrl = originUrl.replacingOccurrences(of: DD_MESSAGE_IMAGE_SUFFIX, with: "")
            // 这个还有可能是http的url???????????????????
            let url = URL.init(fileURLWithPath: originUrl)
            var photos = [URL]()
            for item in self.module.showingMessages {
                if let message = item as? MTTMessageEntity {
                    var url: URL?
                    if message.msgContentType == .DDMessageTypeImage {
                        var urlString = message.msgContent
                        urlString = urlString.replacingOccurrences(of: DD_MESSAGE_IMAGE_PREFIX, with: "")
                        urlString = urlString.replacingOccurrences(of: DD_MESSAGE_IMAGE_SUFFIX, with: "")
                        if urlString.range(of: "\"local\" : ") != nil {
                            let dic = MTTUtil.jsonStringToDictionary(text: urlString)
                            url = URL.init(fileURLWithPath: dic?["url"] as! String)
                        } else {
                            url = URL.init(fileURLWithPath: urlString)
                        }
                        
                        if url != nil {
                            photos.append(url!)
                        }
                    }
                }
            }
            
            /*
            DDChatImagePreviewViewController *preViewControll = [DDChatImagePreviewViewController new];
            NSMutableArray *array = [NSMutableArray array];
            [photos enumerateObjectsUsingBlock:^(NSURL *obj, NSUInteger idx, BOOL *stop) {
                [array addObject:[MWPhoto photoWithURL:obj]];
                }];
            preViewControll.photos=array;
            preViewControll.index=[photos indexOfObject:url];
            //        [preViewControll addChildViewController:preViewControll];
            
            [self presentViewController:preViewControll animated:YES completion:NULL];
            */
        }
        
        cell?.preview = cell?.tapInBubble
        
        return cell!
    }
    
    //MARK: - Notification
    func notificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(n_receiveMessage(notification:)), name: DDNotificationReceiveMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleWillShowKeyboard(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleWillHideKeyboard(notification:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloginSuccess), name: NSNotification.Name("ReloginSuccess"), object: nil)
    }
    
    func n_receiveMessage(notification: Notification) {
    
    }
    
    func handleWillShowKeyboard(notification: Notification) {
        
        if var keyboardRect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            print(keyboardRect.origin.x)
            print(keyboardRect.origin.y)
            print(keyboardRect.size.width)
            print(keyboardRect.size.height)
            keyboardRect = self.view.convert(keyboardRect, from: nil)
            self.bottomShowComponent = DDBottomShowComponent.init(rawValue: ((self.bottomShowComponent.rawValue) | DDBottomShowComponent.DDShowKeyboard.rawValue))!
            UIView.animate(withDuration: 0.25) {
                self.chatInputView?.frame = CGRect.init(x: 0, y: keyboardRect.origin.y - (self.chatInputView?.frame.size.height)!, width: self.view.frame.size.width, height: (self.chatInputView?.frame.size.height)!)
            }
            
            self.inputViewY = keyboardRect.origin.y - (self.chatInputView?.frame.size.height)!
            //self.setValue(keyboardRect.origin.y - self.chatInputView.frame.size.height, forKeyPath: "inputViewY")
        }
    }
    
    func handleWillHideKeyboard(notification: Notification) {
    
    }
    
    func reloginSuccess() {
    
    }
    
    private func sendMessage(msg: String, messageEntity message: MTTMessageEntity) {
        let isGroup = self.module.MTTSessionEntity?.isGroup()
        DDMessageSendManager.sharedInstance.sendMessage(message: message, isGroup: isGroup!, session: self.module.MTTSessionEntity!, completion: { (theMessage: MTTMessageEntity?, error: NSError?) in
            DispatchQueue.main.async {
                message.state = (theMessage?.state)!
                self.tableView.reloadData()
                self.scrollToBottomAnimated(animated: true)
            }
        }) { (error: NSError) in
            self.tableView.reloadData()
        }
    }

    //MARK: JSMessageInputViewDelegate
    func viewHeightChanged(height: CGFloat) {
        // [self setValue:@(self.chatInputView.origin.y) forKeyPath:@"inputViewY"];
    }
    
    func textViewEnterSend() {
        // 发送消息
        do {
            let text = self.chatInputView?.textView?.text
            DDLog(text)
            let pattern = "\\s"
            let reg = try NSRegularExpression.init(pattern: pattern, options: .caseInsensitive)
            let checkoutText = reg.stringByReplacingMatches(in: text!, options: .reportProgress, range: NSRange.init(location: 0, length: (text?.characters.count)!), withTemplate: "")
            if checkoutText.characters.count == 0 {
                return
            }
            
            DDLog(checkoutText)
            
            let msgContentType = DDMessageContentType.DDMessageTypeText
            let message = MTTMessageEntity.makeMessage(content: text!, module: self.module, type: msgContentType)
            self.tableView.reloadData()
            self.chatInputView?.textView?.text = nil
            MTTDatabaseUtil.sharedInstance.insertMessage(messageArray: [message], success: {
                DDLog("消息插入DB成功")
            }, failure: { (errorDescription: String) in
                DDLog("消息插入DB失败")
            })
            
            self.sendMessage(msg: text!, messageEntity: message)
            
        } catch {
            DDLog("发送消息创建正则表达式失败")
        }
    }
    
    func textViewChanged() {
        let range = self.chatInputView?.textView?.selectedRange
        let location = range?.location
        // 可能和@某人的功能相关
        /*
        if location! > 0 {
            let range = NSRange.init(location: location - 1, length: 1)
            var lastText = text
        }
        */
    }
}
