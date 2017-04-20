//
//  LoginViewController.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2016/12/29.
//  Copyright © 2016年 Hello World Corporation. All rights reserved.
//

import UIKit
import MBProgressHUD
import SCLAlertView_Objective_C

class LoginViewController: MTTBaseViewController, UITextFieldDelegate {
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleWillShowKeyboard), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleWillHideKeyboard), name: .UIKeyboardWillHide, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if UserDefaults.standard.string(forKey: "username") != nil {
            self.userNameTextField.text = UserDefaults.standard.string(forKey: "username")
        }
        if UserDefaults.standard.string(forKey: "password") != nil {
            self.userPassTextField.text = UserDefaults.standard.string(forKey: "password")
        }
        if !self.isRelogin {
            if (UserDefaults.standard.string(forKey: "username") != nil) && (UserDefaults.standard.string(forKey: "password") != nil) {
                if UserDefaults.standard.bool(forKey: "autologin") {
                    self.loginButtonPressed(AnyObject.self)
                }
            }
        }
        
        self.defaultCenter = self.view.center
        self.userNameTextField.leftViewMode = .always
        self.userPassTextField.leftViewMode = .always
        
        let usernameLeftView = UIImageView()
        usernameLeftView.contentMode = .center
        usernameLeftView.frame = CGRect.init(x: 0, y: 0, width: 18, height: 22.5)
        
        let pwdLeftView = UIImageView()
        pwdLeftView.contentMode = .center
        pwdLeftView.frame = CGRect.init(x: 0, y: 0, width: 18, height: 22.5)
        
        self.userNameTextField.leftView = usernameLeftView
        self.userPassTextField.leftView = pwdLeftView
        
        self.userNameTextField.layer.borderColor = UIColor.init(red: 211, green: 211, blue: 211, alpha: 1).cgColor
        self.userNameTextField.layer.borderWidth = 0.5
        self.userNameTextField.layer.cornerRadius = 4
        
        self.userPassTextField.layer.borderColor = UIColor.init(red: 211, green: 211, blue: 211, alpha: 1).cgColor
        self.userPassTextField.layer.borderWidth = 0.5
        self.userPassTextField.layer.cornerRadius = 4
        
        self.userLoginBtn.layer.cornerRadius = 4
        
        let touchGR = UITapGestureRecognizer.init(target: self, action: #selector(hiddenKeyboard))
        self.view.addGestureRecognizer(touchGR)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.defaultCenter = self.view.center
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: keyboard hide and show notification
    func handleWillShowKeyboard() {
        UIView.animate(withDuration: 0.2) { 
            self.view.center = CGPoint.init(x: self.view.center.x, y: self.defaultCenter.y - (IPHONE4() ? 120 : 40))
        }
    }
    
    func handleWillHideKeyboard() {
        UIView.animate(withDuration: 0.2) { 
            self.view.center = self.defaultCenter
        }
    }
    
    //MARK: Action
    func hiddenKeyboard() {
        self.userNameTextField.resignFirstResponder()
        self.userPassTextField.resignFirstResponder()
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.userLoginBtn.isEnabled = false
        let userName = self.userNameTextField.text
        let password = self.userPassTextField.text
        if userName?.characters.count == 0 || password?.characters.count == 0 {
            self.userLoginBtn.isEnabled = true
            return
        }
        
        let HUD = MBProgressHUD.init(view: self.view)
        self.view.addSubview(HUD!)
        HUD?.show(true)
        HUD?.dimBackground = true
        HUD?.labelText = "正在登陆"
        
        let alert = SCLAlertView()
        LoginModule.sharedInstance.login(name: userName!, password: password!, success: { (user: MTTUserEntity) in
            HUD?.removeFromSuperview()
            self.userLoginBtn.isEnabled = true
            RuntimeStatus.sharedInstance.user = user
            RuntimeStatus.sharedInstance.updateData()
            if RuntimeStatus.sharedInstance.pushToken != nil {
                let pushToken = SendPushTokenAPI()
                pushToken.requestWithObject(object: RuntimeStatus.sharedInstance.pushToken, completion: { (response: Any?, error: Error?) in
                    // 什么都不做
                })
            }
            
            let rootVC = UIStoryboard.init(name: "Root", bundle: nil).instantiateViewController(withIdentifier: "RootVC")
            self.navigationController?.pushViewController(rootVC, animated: true)
        }) { (error: Error) in
            HUD?.removeFromSuperview()
            // 什么都不提示
            self.userLoginBtn.isEnabled = true
            alert.showError(self, title: "错误", subTitle: error.localizedDescription, closeButtonTitle: "确定", duration: 0)
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.loginButtonPressed(AnyObject.self)
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var userPassTextField: UITextField!
    
    @IBOutlet weak var userLoginBtn: UIButton!
    
    private var isRelogin: Bool = false
    
    private var defaultCenter: CGPoint = CGPoint.init(x: 0, y: 0)
}
