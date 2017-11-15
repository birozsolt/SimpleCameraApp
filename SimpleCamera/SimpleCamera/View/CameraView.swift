//
//  CameraView.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 25/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import AVFoundation
import UIKit
import PureLayout

protocol CameraViewProtocol {
    func captureButtonTapped()
    func toggleCameraButtonTapped()
}

class CameraView: UIView {
    
    public var delegate: CameraViewProtocol?
    
    public var previewView = UIImageView()
    public var videoPreviewView = UIView()
    public var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    public var settingsViewController = SettingsViewController()
    public var orientationViewController = OrientationViewController()
    
    
    private var captureButton = UIButton(type: UIButtonType.custom)
    private var toggleCameraButton = UIButton(type: UIButtonType.custom)
    private var toggleSettingsButton = UIView()
    private var settingsButtonArrow = UIImageView()
    private var settingsButtonView = UIImageView()
    
    private var arrowFrame = CGRect()
    private var settingsFrame = CGRect()
    
    public var isSettingsOpened = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(previewView)
        
        self.insertSubview(captureButton, aboveSubview: previewView)
        self.insertSubview(toggleCameraButton, aboveSubview: previewView)
        self.insertSubview(toggleSettingsButton, aboveSubview: previewView)
        self.insertSubview(settingsViewController.view, aboveSubview: previewView)
        self.insertSubview(orientationViewController.view, aboveSubview: previewView)
        
        self.insertSubview(videoPreviewView, belowSubview: previewView)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        previewView.autoPinEdgesToSuperviewEdges()
        previewView.isHidden = true
        previewView.alpha = 0.0
        previewView.backgroundColor = UIColor.blue
        
        videoPreviewView.autoPinEdgesToSuperviewEdges()
        
        setupSettingsView()
        
        setupOrientationView()
        
        captureButton.isHidden = false
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        captureButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
        captureButton.autoAlignAxis(toSuperviewAxis: .vertical)
        captureButton.autoSetDimensions(to: CGSize(width: 50, height: 50))
        captureButton.layer.cornerRadius = 25
        captureButton.backgroundColor = UIColor.clear
        captureButton.setImage(#imageLiteral(resourceName: "CaptureInactive"), for: .normal)
        captureButton.setImage(#imageLiteral(resourceName: "CaptureActive"), for: .highlighted)
        
        toggleCameraButton.addTarget(self, action: #selector(toggleCamera), for: .touchUpInside)
        toggleCameraButton.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        toggleCameraButton.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
        toggleCameraButton.autoSetDimensions(to: CGSize(width: 30, height: 30))
        toggleCameraButton.backgroundColor = UIColor.clear
        toggleCameraButton.layer.cornerRadius = 15
        toggleCameraButton.setImage(#imageLiteral(resourceName: "CameraRear"), for: .normal)
        
        setupSettingsButton()
    }
    
    func setupSettingsButton(){
        settingsButtonView = UIImageView(image: #imageLiteral(resourceName: "SettingView"))
        settingsButtonArrow.image = #imageLiteral(resourceName: "ArrowRight")
        
        toggleSettingsButton.autoAlignAxis(.horizontal, toSameAxisOf: captureButton)
        toggleSettingsButton.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        toggleSettingsButton.autoSetDimensions(to: CGSize(width: 40, height: 30))
        toggleSettingsButton.backgroundColor = UIColor.clear
        toggleSettingsButton.addSubview(settingsButtonArrow)
        toggleSettingsButton.addSubview(settingsButtonView)
        
        settingsButtonArrow.autoPinEdge(.left, to: .left, of: toggleSettingsButton)
        settingsButtonArrow.autoPinEdge(.bottom, to: .bottom, of: toggleSettingsButton)
        settingsButtonArrow.autoPinEdge(.top, to: .top, of: toggleSettingsButton)
        settingsButtonArrow.autoSetDimension(.width, toSize: 10)
        settingsButtonArrow.contentMode = .scaleAspectFill
        
        settingsButtonView.autoPinEdge(.left, to: .right, of: settingsButtonArrow)
        settingsButtonView.autoPinEdge(.bottom, to: .bottom, of: toggleSettingsButton)
        settingsButtonView.autoPinEdge(.top, to: .top, of: toggleSettingsButton)
        settingsButtonView.autoSetDimension(.width, toSize: 30)
        
        arrowFrame = self.convert(settingsButtonArrow.frame, from: toggleSettingsButton)
        settingsFrame = self.convert(settingsButtonView.frame, from: toggleSettingsButton)
        
        toggleSettingsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleSettings)))
    }
    
    func setupSettingsView() {
        settingsViewController.view.autoPinEdge(toSuperviewEdge: .left)
        settingsViewController.view.autoPinEdge(.bottom, to: .top, of: captureButton, withOffset: -20)
        settingsViewController.view.autoSetDimensions(to: CGSize(width: self.previewView.frame.size.width, height: 160))
    }
    
    func setupOrientationView(){
        orientationViewController.view.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
        orientationViewController.view.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        orientationViewController.view.autoSetDimensions(to: CGSize(width: 100 , height: 100))
    }
    
    func changeCameraImage(to image: UIImage){
        toggleCameraButton.setImage(image, for: .normal)
    }
    
    func changeArrowImage(to image: UIImage){
        settingsButtonArrow.image = image
    }
    
    // MARK: - Button handlers
    func capturePhoto() {
        delegate?.captureButtonTapped()
    }
    
    func toggleCamera(){
        delegate?.toggleCameraButtonTapped()
    }
    
    func toggleSettings() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            if !self.isSettingsOpened {
                self.showSettings()
                self.isSettingsOpened = true
            } else {
                self.hideSettings()
                self.isSettingsOpened = false
            }
        }) { (finished) in
            if !self.isSettingsOpened {
                self.settingsViewController.view.isHidden = true
                self.changeArrowImage(to: #imageLiteral(resourceName: "ArrowRight"))
            } else {
                self.settingsViewController.view.isHidden = false
                self.changeArrowImage(to: #imageLiteral(resourceName: "ArrowLeft"))
            }
        }
    }
    
    func showSettings(){
        settingsViewController.view.frame = CGRect(x: 0,
                                                    y: previewView.frame.size.height - 250,
                                                    width: previewView.frame.size.width,
                                                    height: 160)
        settingsViewController.view.isHidden = false
        animateSettingsButton(to: isSettingsOpened)
    }
    
    func hideSettings(){
        settingsViewController.view.frame = CGRect(x: 0 - previewView.frame.size.width,
                                                    y: previewView.frame.size.height - 250,
                                                    width: previewView.frame.size.width,
                                                    height: 160)
        animateSettingsButton(to: isSettingsOpened)

    }
    
    func animateSettingsButton(to settingsOpened: Bool) {
        if !settingsOpened {
            settingsButtonArrow.image = #imageLiteral(resourceName: "ArrowLeft")
            settingsButtonArrow.frame = CGRect(x: arrowFrame.origin.x + 20,
                                               y: arrowFrame.origin.y,
                                               width: 10,
                                               height: 30)
            
            settingsButtonView.frame = CGRect(x: self.settingsFrame.origin.x - 10,
                                              y: settingsFrame.origin.y,
                                              width: 30,
                                              height: 30)
        } else {
            self.settingsButtonArrow.image = #imageLiteral(resourceName: "ArrowRight")
            self.settingsButtonArrow.frame = CGRect(x: self.arrowFrame.origin.x,
                                                    y: self.arrowFrame.origin.y,
                                                    width: 10,
                                                    height: 30)
            
            self.settingsButtonView.frame = CGRect(x: self.settingsFrame.origin.x + 10,
                                                   y: self.settingsFrame.origin.y,
                                                   width: 30,
                                                   height: 30)
        }
    }
}
