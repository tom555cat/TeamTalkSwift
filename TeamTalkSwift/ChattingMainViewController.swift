//
//  ChattingMainViewController.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/2/23.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit

class ChattingMainViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate {

    lazy var module: ChattingModule = ChattingModule.init()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatInputView: UIView!
    @IBOutlet weak var headerView: UIView!
    var hadLoadHistory: Bool = false
    static let sharedInstance = UIStoryboard.init(name: "Contacts", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! ChattingMainViewController
    // RecordingView* _recordingView;
    
    //MARK: - Private Property
    private var titleBtn: UIButton?
    //private var touchDownGestureRecognizer:
    
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
        self.module.loadMoreHistoryCompletion { (addCount: UInt32, error: NSError?) in
            self.tableView.reloadData()
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
    
    }
    
    func initialInput() {
        //self.chatInputView.delegate = self
        self.chatInputView.backgroundColor = UIColor.init(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 0.9)
        //self.chatInputView.emotionbutton.addTarget(self, action: #selector(showEmotions(sender:)), for: .touchUpInside)
        //self.chatInputView.showUtilitysbutton.addTarget(self, action: #selector(showUtilitys(sender:)), for: .touchDown)
        //self.chatInputView.voiceButton.addTarget(self, action: #selector(p_clickThRecordButton(sender:)), for: .touchUpInside)
        
        /*
         _touchDownGestureRecognizer = [[TouchDownGestureRecognizer alloc] initWithTarget:self action:nil];
         __weak ChattingMainViewController* weakSelf = self;
         _touchDownGestureRecognizer.touchDown = ^{
         [weakSelf p_record:nil];
         };
         
         _touchDownGestureRecognizer.moveInside = ^{
         [weakSelf p_endCancelRecord:nil];
         };
         
         _touchDownGestureRecognizer.moveOutside = ^{
         [weakSelf p_willCancelRecord:nil];
         };
         
         _touchDownGestureRecognizer.touchEnd = ^(BOOL inside){
         if (inside)
         {
         [weakSelf p_sendRecord:nil];
         }
         else
         {
         [weakSelf p_cancelRecord:nil];
         }
         };
         [self.chatInputView.recordButton addGestureRecognizer:_touchDownGestureRecognizer];
         _recordingView = [[RecordingView alloc] initWithState:DDShowVolumnState];
         [_recordingView setHidden:YES];
         [_recordingView setCenter:CGPointMake(FULL_WIDTH/2, self.view.centerY)];
         [self addObserver:self forKeyPath:@"_inputViewY" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Action
    
    func Edit(sender: Any) {
    
    }
    
    func initScrollView() {
    
    }
    
    func p_tapOnTableView(recognizer: UIPanGestureRecognizer) {
    
    }
    
    func showEmotions(sender: Any) {
    
    }
    
    func showUtilitys(sender: Any) {
    
    }
    
    func p_clickThRecordButton(sender: Any) {
    
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
    
    //MARK: - UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            } else {
                cell = self.p_textCell(tableView: tableView, cellForRowAtIndexPath: indexPath, message: message)
            }
        } else {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "nothing")
        }
        return cell!
    }
    
    //MARK: - Private API
    func p_textCell(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, message: MTTMessageEntity) -> UITableViewCell {
        let identifier = "DDChatTextCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DDChatBaseCell
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
        
        if UnAckMessageManager.sharedInstance.isInUnAckQueue(message: message) && message.state == .DDMessageSending && message.isSendBySelf() {
            message.state = .DDMessageSendFailure
        }
        
        MTTDatabaseUtil.sharedInstance.updateMessage(message: message) { (result: Bool) in
            // 什么都不做
        }
        
        cell?.setContent(content: message)
        weak var weakCell = cell as? DDChatTextCell
        cell?.sendAgain = {
            weakCell?.showSending()
            weakCell?.sendTextAgain(message: message)
        }
        
        return cell!
    }
    
    /*
    func p_promptCell(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, message: DDPromptEntity) -> UITableViewCell {
        let identifier = "DDPromptCellIdentifier"
        //var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DDPro
    }
    */
    
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
    
    }
    
    func handleWillHideKeyboard(notification: Notification) {
    
    }
    
    func reloginSuccess() {
    
    }

    
}
