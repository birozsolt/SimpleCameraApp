//
//  CameraViewController.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 25/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    var cameraView = CameraView(frame: CGRect.zero)
    
    let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil) // queue for session opbject communication.
    var session = AVCaptureSession()
    var stillImageOutput: AVCaptureStillImageOutput?
    var captureDevice: AVCaptureDevice?
    
    var input: AVCaptureDeviceInput!
    var error: NSError?
    var hasCamera = true
    var isCameraAlreadySetUp = false
    
    // MARK: LIFECYCLE
    
    override func loadView() {
        self.view = cameraView
        cameraView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerToNotificationCenter()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCamera()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopSession()
    }
    
    // MARK: SETUP CAPTURE DEVICE
    
    func setupCamera() {
        if isCameraAlreadySetUp { return }
        isCameraAlreadySetUp = true
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        let devices = AVCaptureDevice.devices()
        if devices?.count == 0 {
            self.setupForDeviceWithoutCamera()
        } else {
            if session.isRunning == false {
                self.setupForDeviceWithCamera()
            }
        }
    }
    
    func setupForDeviceWithoutCamera() {
        hasCamera = false
        cameraView.setupSubviewsForDeviceWithoutCamera()
    }
    
    func setupForDeviceWithCamera() {
        sessionQueue.async {
            let devices = AVCaptureDevice.devices()
            DispatchQueue.main.async {
                LoadingBox.sharedInstance.block()
                
                self.hasCamera = true
            }
            for device in devices! {
                if (device as AnyObject).hasMediaType(AVMediaTypeVideo) {
                    if (device as AnyObject).position == AVCaptureDevicePosition.back {
                        self.captureDevice = device as? AVCaptureDevice
                        if self.captureDevice != nil {
                            self.beginSession()
                        }
                    }
                }
            }
            
            self.stillImageOutput = AVCaptureStillImageOutput()
            self.stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if self.session.canAddOutput(self.stillImageOutput) {
                self.session.addOutput(self.stillImageOutput)
            }
            DispatchQueue.main.async {
                self.cameraView.previewView.isHidden = true
                self.cameraView.videoPreviewLayer?.isHidden = false
                self.cameraView.previewView.alpha = 0.0
            }
        }
    }
    
    // MARK: SETUP OBSERVER FOR ORIENTATION CHANGE
    
    func registerToNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: ROTATION HANDLER FUNCTION
    
    func rotated() {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .landscapeLeft: self.changeVideoOrientation(orientation: .landscapeLeft)
        case .landscapeRight : self.changeVideoOrientation(orientation: .landscapeRight)
        case .portrait : self.changeVideoOrientation(orientation: .portrait)
        case .portraitUpsideDown : self.changeVideoOrientation(orientation: .portraitUpsideDown)
        default: self.changeVideoOrientation(orientation: .portrait)
        }
    }
    
    func changeVideoOrientation(orientation: AVCaptureVideoOrientation){
        guard let connection = self.cameraView.videoPreviewLayer?.connection else { return }
        connection.videoOrientation = orientation
    }
    
    func getFrameForImagePreview() -> CGRect {
        self.cameraView.previewView.frame = CGRect(x: 0,
                                                   y: 0,
                                                   width: self.view.frame.size.width,
                                                   height: self.view.frame.size.height)
        let contentFrame = self.cameraView.previewView.getTheFrameOfContent(contentMode: .scaleAspectFit)
        return CGRect(x: (self.view.frame.size.width - contentFrame.size.width)/2,
                      y: (self.view.frame.size.height - contentFrame.size.height)/2,
                      width: contentFrame.size.width,
                      height: contentFrame.size.height)
    }
}
