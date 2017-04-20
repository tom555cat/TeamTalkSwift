//
//  EmotionsViewController.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/3/27.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit

let keyboardHeight: CGFloat = 180
let facialViewHeight: CGFloat = 170

protocol DDEmotionsViewControllerDelegate {
    func emotionViewClickSendButton()
}

class EmotionsViewController: UIViewController, UIScrollViewDelegate{
    
    var scrollView: UIScrollView?
    var pageControl: UIPageControl?
    var emotions: [String]?
    var isOpen: Bool = false
    var delegate: DDEmotionsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.frame = CGRect.init(x: 0, y: 0, width: FULL_WIDTH, height: 216)
        self.emotions = Array((EmotionsModule.sharedInstance.emotionUnicodeDic?.keys)!)
        if self.scrollView == nil {
            self.scrollView = UIScrollView.init(frame: self.view.frame)
            self.scrollView?.backgroundColor = UIColor.white
            for i in 0..<3 {
                self.p_loadFacialViewWithRow(page: i, size: CGSize.init(width: (FULL_WIDTH-10)/4, height: 90))
            }
        }
        
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.showsHorizontalScrollIndicator = false
        self.scrollView?.contentSize = CGSize.init(width: FULL_WIDTH * 3, height: keyboardHeight)
        self.scrollView?.isPagingEnabled = true
        self.scrollView?.delegate = self
        self.view.addSubview(self.scrollView!)
        
        self.pageControl = UIPageControl.init(frame: CGRect.init(x: self.view.frame.size.width / 2 - 70, y: self.view.frame.size.height - 30, width: 150, height: 30))
        self.pageControl?.currentPage = 0
        self.pageControl?.pageIndicatorTintColor = UIColor.gray
        self.pageControl?.currentPageIndicatorTintColor = RGB(245, 62, 102)
        self.pageControl?.numberOfPages = 3
        self.pageControl?.backgroundColor = UIColor.white
        self.pageControl?.addTarget(self, action: #selector(changePage(sender:)), for: UIControlEvents.valueChanged)
        self.view.addSubview(self.pageControl!)
        self.view.backgroundColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: ScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageControl?.currentPage = Int((self.scrollView?.contentOffset.x)!) / Int(FULL_WIDTH)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl?.currentPage = Int((self.scrollView?.contentOffset.x)!) / Int(FULL_WIDTH)
    }
    
    //MARK: Private Function
    func selectedFacialView(str: String) {
        if str == "delete" {
            ChattingMainViewController.sharedInstance.deleteEmojiFace()
            return
        }
        ChattingMainViewController.sharedInstance.insertEmojiFace(string: str)
    }
    
    func changePage(sender: Any) {
        self.scrollView?.contentOffset = CGPoint.init(x: FULL_WIDTH * CGFloat((self.pageControl?.currentPage)!), y: 0)
    }
    
    func clickTheSendButton(sender: Any) {
        if self.delegate != nil {
            self.delegate?.emotionViewClickSendButton()
        }
    }
    
    func p_loadFacialViewWithRow(page: Int, size: CGSize) {
        let emotions = Array((EmotionsModule.sharedInstance.emotionUnicodeDic?.keys)!)
        let yayaview = UIView.init(frame: CGRect.init(x: 12 + FULL_WIDTH * CGFloat(page), y: 15, width: FULL_WIDTH - 30, height: facialViewHeight))
        yayaview.backgroundColor = UIColor.clear
        
        for i in 0..<2 {
            for y in 0..<4 {
                let button = UIButton.init(frame: CGRect.init(x: CGFloat(y) * size.height, y: CGFloat(i) * size.height, width: size.width, height: size.height))
                button.backgroundColor = UIColor.clear
                
                if i * 4 + y + page * 8 >= emotions.count {
                    break
                } else {
                    button.titleLabel?.font = UIFont.init(name: "AppleColorEmoji", size: 27.0)
                    button.setTitle(emotions[i * 4 + y + page * 8], for: .normal)
                    button.tag = i * 4 + y + page * 8
                    let emotionStr = EmotionsModule.sharedInstance.emotionUnicodeDic?[emotions[i * 4 + y + page * 8]] as! String
                    let emotionImage = UIImage.init(named: emotionStr)
                    button.setImage(emotionImage, for: .normal)
                    button.addTarget(self, action: #selector(p_selected(button:)), for: .touchUpInside)
                    yayaview.addSubview(button)
                }
            }
        }
        
        self.scrollView?.addSubview(yayaview)
    }
    
    func p_selected(button: UIButton) {
        let emotions = EmotionsModule.sharedInstance.emotions
        let str = emotions?[button.tag] as! String
        self.selectedFacialView(str: str)
    }
}
