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
    func toggleFlashButtonTapped()
    func toggleCameraButtonTapped()
}

class CameraView: UIView {
    
    public var delegate: CameraViewProtocol?
    
    public var previewView = UIImageView()
    public var videoPreviewView = UIView()
    public var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private var captureButton = UIButton(type: UIButtonType.custom)
    private var toggleFlashButton = UIButton(type: UIButtonType.custom)
    private var toggleCameraButton = UIButton(type: UIButtonType.custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(previewView)
        self.insertSubview(captureButton, aboveSubview: previewView)
        self.insertSubview(toggleFlashButton, aboveSubview: previewView)
        self.insertSubview(toggleCameraButton, aboveSubview: previewView)
        
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
        
        videoPreviewView.autoPinEdgesToSuperviewEdges()
        
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
        
        toggleFlashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        toggleFlashButton.autoPinEdge(.top, to: .bottom, of: toggleCameraButton, withOffset: 10)
        toggleFlashButton.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
        toggleFlashButton.autoSetDimensions(to: CGSize(width: 30, height: 30))
        toggleFlashButton.backgroundColor = UIColor.clear
        toggleFlashButton.layer.cornerRadius = 15
        toggleFlashButton.setImage(#imageLiteral(resourceName: "FlashOff"), for: .normal)
    }
    
    func setupSubviewsForDeviceWithoutCamera() {
        captureButton.isUserInteractionEnabled = false
        previewView.isHidden = false
        previewView.backgroundColor = UIColor.gray
        videoPreviewLayer?.isHidden = true
        previewView.alpha = 1.0
    }
    
    func changeFlashButtonImage(to image: UIImage){
        toggleFlashButton.setImage(image, for: .normal)
    }
    
    func changeCameraImage(to image: UIImage){
        toggleCameraButton.setImage(image, for: .normal)
    }
    
    // MARK: - Button handlers
    func capturePhoto() {
        delegate?.captureButtonTapped()
    }
    
    func toggleFlash(){
        delegate?.toggleFlashButtonTapped()
    }
    
    func toggleCamera(){
        delegate?.toggleCameraButtonTapped()
    }
}
