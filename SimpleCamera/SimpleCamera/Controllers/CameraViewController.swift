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
    
    var captureSession : AVCaptureSession?
    var photoOutput: AVCaptureStillImageOutput?
    var captureDevice: AVCaptureDevice?
    
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var hasCamera = true
    var isCameraAlreadySetUp = false
    var currentCameraPosition: CameraPosition?
    
    // MARK: LIFECYCLE
    
    override func loadView() {
        self.view = cameraView
        cameraView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerToNotificationCenter()
        cameraView.orientationViewController.startMotionUpdate()
        prepare(completionHandler: { (error) in
            if let error = error {
                print(error)
            }
            try? self.displayPreview()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let captureSession = self.captureSession, captureSession.isRunning else { return }
        captureSession.stopRunning()
        cameraView.orientationViewController.stopMotionUpdate()
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
}
