//
//  CameraViewControllerExtension.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 31/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit
import AVFoundation

extension CameraViewController {
    
    enum CameraPosition {
        case front
        case rear
    }
    
    public enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            let session = AVCaptureSession()
            session.sessionPreset = AVCaptureSessionPresetPhoto
            
            guard let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo), !devices.isEmpty else { throw CameraControllerError.noCamerasAvailable }
            
            for device in devices {
                print(devices.count)
                let device = device as! AVCaptureDevice
                if device.position == .front {
                    self.frontCamera = device
                }
                
                if device.position == .back {
                    self.rearCamera = device
                    
                    try device.lockForConfiguration()
                    device.focusMode = .autoFocus
                    device.unlockForConfiguration()
                }
            }
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
                
                self.currentCameraPosition = .rear
            }
                
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }
                
                self.currentCameraPosition = .front
            }
                
            else { throw CameraControllerError.noCamerasAvailable }
        }
        
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            self.photoOutput = AVCaptureStillImageOutput()
            self.photoOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            if captureSession.canAddOutput(self.photoOutput) { captureSession.addOutput(self.photoOutput) }
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview() throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft: self.changeVideoOrientation(orientation: .landscapeRight)
        case .landscapeRight : self.changeVideoOrientation(orientation: .landscapeLeft)
        case .portrait : self.changeVideoOrientation(orientation: .portrait)
        default: self.changeVideoOrientation(orientation: .portrait)
        }
        cameraView.videoPreviewView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        videoPreviewLayer?.frame = CGRect(origin: CGPoint.zero, size: cameraView.videoPreviewView.frame.size)
        cameraView.videoPreviewView.layer.insertSublayer(videoPreviewLayer!, above: cameraView.videoPreviewView.layer)
    }
    
    func switchCameras() throws {
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws { }
        func switchToRearCamera() throws { }
        
        switch currentCameraPosition {
        case .front:
            cameraView.changeCameraImage(to: #imageLiteral(resourceName: "CameraRear"))
            try switchToRearCamera()
            
        case .rear:
            cameraView.changeCameraImage(to: #imageLiteral(resourceName: "CameraFront"))
            try switchToFrontCamera()
        }
        
        captureSession.commitConfiguration()
    }
    
    func switchToFrontCamera() throws {
        guard let inputs = captureSession?.inputs as? [AVCaptureInput], let rearCameraInput = self.rearCameraInput, inputs.contains(rearCameraInput),
            let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
        
        self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
        
        captureSession?.removeInput(rearCameraInput)
        
        if (captureSession?.canAddInput(self.frontCameraInput!))! {
            captureSession?.addInput(self.frontCameraInput!)
            
            self.currentCameraPosition = .front
            captureDevice = frontCamera
        }
            
        else { throw CameraControllerError.invalidOperation }
    }
    
    func switchToRearCamera() throws {
        guard let inputs = captureSession?.inputs as? [AVCaptureInput], let frontCameraInput = self.frontCameraInput, inputs.contains(frontCameraInput),
            let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
        
        self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
        
        captureSession?.removeInput(frontCameraInput)
        
        if (captureSession?.canAddInput(self.rearCameraInput!))! {
            captureSession?.addInput(self.rearCameraInput!)
            
            self.currentCameraPosition = .rear
            captureDevice = rearCamera
        }
            
        else { throw CameraControllerError.invalidOperation }
    }
}

// MARK: - CameraViewProtocol
extension CameraViewController: CameraViewProtocol {
    
    func captureButtonTapped() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            if self.cameraView.isSettingsOpened {
                self.cameraView.hideSettings()
                self.cameraView.isSettingsOpened = false
            }
        }) { (finished) in
            self.cameraView.settingsViewController.view.isHidden = true
            self.cameraView.changeArrowImage(to:#imageLiteral(resourceName: "ArrowRight"))
        }

        captureImage{ (image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            self.imageArray.append(image)
            /*
            self.cameraView.previewView.isHidden = false
            self.cameraView.previewView.contentMode = .scaleAspectFit
            self.cameraView.previewView.backgroundColor = UIColor.black
            self.cameraView.previewView.alpha = 1.0
            self.videoPreviewLayer?.isHidden = true

            self.cameraView.previewView.image = image*/
        }
    }
    
    // MARK: BUTTON HANDLER
    
    //swiftlint:disable force_cast
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        
        if hasCamera {
            if let videoConnection = (captureSession.outputs[0] as? AVCaptureStillImageOutput)?.connection(withMediaType: AVMediaTypeVideo){
                (captureSession.outputs[0] as? AVCaptureStillImageOutput)?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (buffer, error) -> Void in
                    if let sampleBuffer = buffer {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                        
                        let dataProvider = CGDataProvider(data: imageData! as CFData)
                        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                        
                        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right) //self.cropImage(image: UIImage(cgImage: cgImageRef!), toRect: self.cameraView.previewView.bounds)
                        completion(image, nil)
                    }
                })
            } else {
                print("Video capture problem")
            }
        }
    }//swiftlint:enable force_cast
    
    func toggleCameraButtonTapped() {
        do {
            try switchCameras()
        }
        catch {
            print(error)
        }
    }
    
    func cropImage(image : UIImage, toRect rect: CGRect) -> UIImage {
        
        func rad(_ deg : CGFloat) -> CGFloat {
            return deg / 180 * .pi
        }
        
        // determine the orientation of the image and apply a transformation to the crop rectangle to shift it to the correct position
        var rectTransform: CGAffineTransform
        switch (image.imageOrientation) {
        case .left:
            rectTransform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -image.size.height)
            break
        case .right:
            rectTransform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -image.size.width, y: 0)
            break
        case .down:
            rectTransform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -image.size.width, y: -image.size.height)
            break
        default:
            rectTransform = CGAffineTransform.identity;
        }
        
        // adjust the transformation scale based on the image scale
        //rectTransform = rectTransform.scaledBy(x: image.scale, y: image.scale);
        
        // apply the transformation to the rect to create a new, shifted rect
        let transformedCropSquare = rect.applying(rectTransform)
        // use the rect to crop the image
        let imageRef = image.cgImage!.cropping(to: transformedCropSquare)
        // create a new UIImage and set the scale and orientation appropriately
        let result = UIImage(cgImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)
        
        return result
    }
}
