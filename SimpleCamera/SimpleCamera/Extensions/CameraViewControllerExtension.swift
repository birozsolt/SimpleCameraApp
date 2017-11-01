//
//  CameraViewControllerExtension.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 31/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit
import AVFoundation

extension CameraViewController: CaptureSessionProtocol {
    
    func beginSession() {
        session.sessionPreset = AVCaptureSessionPresetPhoto
        do {
            try input =  AVCaptureDeviceInput(device: captureDevice)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && session.canAddInput(input) {
            session.addInput(input)
        }
        
        DispatchQueue.main.async {
            //let ratio = CGFloat(4.0 / 3.0) //resolution.width / resolution.height
            let videoPreviewWidth = self.view.frame.width
            let videoPreviewHeight = self.view.frame.height
            let videoPreviewViewFrame = CGRect(x: 0,
                                               y: 0,
                                               width: videoPreviewWidth,
                                               height: videoPreviewHeight)
            let videoPreviewLayerFrame = CGRect(origin: CGPoint.zero, size: videoPreviewViewFrame.size)
            
            self.cameraView.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            self.cameraView.videoPreviewView.frame = videoPreviewViewFrame
            self.cameraView.videoPreviewLayer!.frame = videoPreviewLayerFrame
            self.cameraView.videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
            self.cameraView.videoPreviewView.layer.insertSublayer(self.cameraView.videoPreviewLayer!, above: self.cameraView.videoPreviewView.layer)
            
            switch UIApplication.shared.statusBarOrientation {
            case .landscapeLeft: self.changeVideoOrientation(orientation: .landscapeLeft)
            case .landscapeRight : self.changeVideoOrientation(orientation: .landscapeRight)
            case .portrait : self.changeVideoOrientation(orientation: .portrait)
            case .portraitUpsideDown : self.changeVideoOrientation(orientation: .portraitUpsideDown)
            default: self.changeVideoOrientation(orientation: .portrait)
            }
            
            self.startSession()
        }
    }
    
    func startSession() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
            DispatchQueue.main.async {
                LoadingBox.sharedInstance.unblock()
                print("start session unblock")
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
}

// MARK: - CameraViewProtocol
extension CameraViewController: CameraViewProtocol {
    
    func takePhotoButtonTapped() {
        self.takePhoto()
    }
    
    // MARK: BUTTON HANDLER
    
    //swiftlint:disable force_cast
    func takePhoto() {
        if let videoConnection = (session.outputs[0] as? AVCaptureStillImageOutput)?.connection(withMediaType: AVMediaTypeVideo) {
            (session.outputs[0] as? AVCaptureStillImageOutput)?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (buffer, error) -> Void in
                if let sampleBuffer = buffer {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    
                    let dataProvider = CGDataProvider(data: imageData! as CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    var imageOrientation: UIImageOrientation
                    
                    /*if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
                     imageOrientation = UIImageOrientation.down
                     } else {
                     imageOrientation = UIImageOrientation.up
                     }*/
                    
                    switch UIDevice.current.orientation {
                    case .landscapeLeft: imageOrientation = UIImageOrientation.left
                    case .landscapeRight : imageOrientation = UIImageOrientation.right
                    case .portrait : imageOrientation = UIImageOrientation.up
                    case .portraitUpsideDown : imageOrientation = UIImageOrientation.down
                    default: imageOrientation = UIImageOrientation.up
                    }
                    
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: imageOrientation)
                    self.cameraView.previewView.image = image
                    self.cameraView.previewView.clipsToBounds = true
                    self.cameraView.previewView.isHidden = false
                    
                    let startingRect = self.cameraView.videoPreviewView.frame
                    let endingRect = self.getFrameForImagePreview()
                    self.cameraView.previewView.contentMode = .scaleAspectFit
                    self.cameraView.previewView.frame = startingRect
                    
                    UIView.animate(withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveLinear, animations: {
                        self.cameraView.previewView.alpha = 1.0
                        self.cameraView.previewView.frame = endingRect
                    }, completion: { _ in
                        self.cameraView.videoPreviewLayer?.isHidden = true
                    })
                }
                if error == nil {
                    self.error = nil
                }
            })
        } else {
            print("Video capture problem")
        }
    }//swiftlint:enable force_cast
}
