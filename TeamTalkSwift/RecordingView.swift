//
//  RecordingView.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/3/16.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit

let DDVIEW_RECORDING_WIDTH: CGFloat = 196
let DDVIEW_RECORDING_HEIGHT: CGFloat = 196

let DDVOLUMN_VIEW_TAG = 10

enum DDRecordingState: Int {
    case DDShowVolumnState
    case DDShowCancelSendState
    case DDShowRecordTimeTooShort
}

class RecordingView: UIView {
    
    var recordingState: DDRecordingState
    
    init(state: DDRecordingState) {
        self.recordingState = state
        super.init(frame: CGRect.init(x: 0, y: 0, width: DDVIEW_RECORDING_WIDTH, height: DDVIEW_RECORDING_HEIGHT))
        self.frame = CGRect.init(x: 0, y: 0, width: DDVIEW_RECORDING_WIDTH, height: DDVIEW_RECORDING_HEIGHT)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.backgroundColor = UIColor.clear
        let backgroundView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: DDVIEW_RECORDING_WIDTH, height: DDVIEW_RECORDING_HEIGHT))
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.7
        backgroundView.tag = 100
        self.addSubview(backgroundView)
        self.recordingState = .DDShowVolumnState
        self.setupShowVolumnState()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.recordingState = .DDShowVolumnState
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    func setVolume(volume: Float) {
        if self.recordingState != .DDShowVolumnState {
            return
        }
        
        let volumnImageView = self.subview(withTag: DDVOLUMN_VIEW_TAG)
        var height = self.height(forVolumn: volume)
        volumnImageView?.setHeight(height: CGFloat(height))
        volumnImageView?.setBottom(bottom: 126)
    }
    
    func setRecordingState(recordingState: DDRecordingState) {
        switch recordingState {
        case .DDShowCancelSendState:
            self.showCancelSendState()
        case .DDShowVolumnState:
            self.showVolumnState()
        case .DDShowRecordTimeTooShort:
            self.showRecordingTooShort()
        }
    }
    
    //MARK: - privateAPI
    private func setupCancelSendView() {
        for obj in self.subviews {
            if obj.tag != 100 {
                obj.removeFromSuperview()
            }
        }
        
        let image = UIImage.init(named: "dd_cancel_send_record")
        let imageView = UIImageView.init(image: image)
        imageView.frame = CGRect.init(x: 74, y: 53, width: 45, height: 59)
        self.addSubview(imageView)
        
        let backgroundView = UIView.init(frame: CGRect.init(x: 28, y: 152, width: 140, height: 23))
        backgroundView.backgroundColor = RGB(176, 34, 33)
        backgroundView.alpha = 0.5
        backgroundView.layer.cornerRadius = 2
        backgroundView.clipsToBounds = true
        self.addSubview(backgroundView)
        
        let prompt = UILabel.init(frame: CGRect.init(x: 28, y: 152, width: 140, height: 23))
        prompt.backgroundColor = UIColor.clear
        prompt.textColor = UIColor.white
        prompt.text = "松开手指，取消发送"
        prompt.font = UIFont.systemFont(ofSize: 15)
        prompt.textAlignment = .center
        self.addSubview(prompt)
    }
    
    private func setupShowVolumnState() {
        for obj in self.subviews {
            if obj.tag != 100 {
                obj.removeFromSuperview()
            }
        }
        
        let image = UIImage.init(named: "dd_recording")
        let imageView = UIImageView.init(image: image)
        imageView.frame = CGRect.init(x: 60, y: 42, width: 53, height: 83)
        self.addSubview(imageView)
        
        let prompt = UILabel.init(frame: CGRect.init(x: 0, y: 152, width: DDVIEW_RECORDING_WIDTH, height: 23))
        prompt.backgroundColor = UIColor.clear
        prompt.textColor = UIColor.white
        prompt.layer.cornerRadius = 2
        prompt.textAlignment = .center
        prompt.font = UIFont.systemFont(ofSize: 15)
        prompt.text = "手指上滑，取消发送"
        self.addSubview(prompt)
        
        let volumnImage = UIImage.init(named: "dd_volumn")
        let volumnImageView = UIImageView.init(image: volumnImage)
        volumnImageView.frame = CGRect.init(x: 119, y: 83, width: 20, height: 43)
        volumnImageView.contentMode = .bottom
        volumnImageView.clipsToBounds = true
        volumnImageView.tag = DDVOLUMN_VIEW_TAG
        self.addSubview(volumnImageView)
    }
    
    private func setupShowRecordingTooShort() {
        for obj in self.subviews {
            if obj.tag != 100 {
                obj.removeFromSuperview()
            }
        }
        
        let image = UIImage.init(named: "dd_record_too_short")
        let imageView = UIImageView.init(image: image)
        imageView.frame = CGRect.init(x: 85, y: 42, width: 22, height: 83)
        self.addSubview(imageView)
        
        let prompt = UILabel.init(frame: CGRect.init(x: 0, y: 152, width: DDVIEW_RECORDING_WIDTH, height: 23))
        prompt.backgroundColor = UIColor.clear
        prompt.textColor = UIColor.white
        prompt.layer.cornerRadius = 2
        prompt.textAlignment = .center
        prompt.font = UIFont.systemFont(ofSize: 15)
        prompt.text = "说话时间太短"
        self.addSubview(prompt)
    }
    
    private func showCancelSendState() {
        if self.recordingState != .DDShowCancelSendState {
            self.setupCancelSendView()
        }
        self.recordingState = .DDShowCancelSendState
    }
    
    private func showVolumnState() {
        if self.recordingState != .DDShowVolumnState {
            self.setupShowVolumnState()
        }
        self.recordingState = .DDShowVolumnState
    }
    
    private func showRecordingTooShort() {
        if self.recordingState != .DDShowRecordTimeTooShort {
            self.setupShowRecordingTooShort()
        }
        self.recordingState = .DDShowRecordTimeTooShort
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(NSEC_PER_SEC)) {
            if self.recordingState == .DDShowRecordTimeTooShort {
                self.isHidden = true
            }
        }
    }
    
    private func height(forVolumn volumn: Float) -> Float {
        let height = 43.0 / 1.6 * volumn
        return height
    }
}
