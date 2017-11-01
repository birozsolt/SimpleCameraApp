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
    func takePhotoButtonTapped()
}

class CameraView: UIView {
    
    public var delegate: CameraViewProtocol?
    
    public var previewView = UIImageView()
    public var videoPreviewView = UIView()
    public var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private var takePhotoButton = UIButton(type: UIButtonType.custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(previewView)
        self.insertSubview(takePhotoButton, aboveSubview: previewView)
        
        
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
        videoPreviewView.clipsToBounds = true

        takePhotoButton.isHidden = false
        takePhotoButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        takePhotoButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
        takePhotoButton.autoAlignAxis(toSuperviewAxis: .vertical)
        takePhotoButton.autoSetDimensions(to: CGSize(width: 150, height: 50))
        takePhotoButton.layer.cornerRadius = 25
        takePhotoButton.backgroundColor = UIColor.darkGray
        takePhotoButton.setTitleColor(UIColor.white, for: .normal)
        takePhotoButton.setTitle("Cheeers!", for: .normal)
        
    }
    
    func setupSubviewsForDeviceWithoutCamera() {
        takePhotoButton.isUserInteractionEnabled = false
        self.previewView.isHidden = false
        self.videoPreviewLayer?.isHidden = true
        previewView.alpha = 1.0
    }
    
    // MARK: - Button handlers
    func takePhoto() {
        delegate?.takePhotoButtonTapped()
    }
}
