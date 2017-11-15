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
        
        cameraView.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraView.videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft: self.changeVideoOrientation(orientation: .landscapeLeft)
        case .landscapeRight : self.changeVideoOrientation(orientation: .landscapeRight)
        case .portrait : self.changeVideoOrientation(orientation: .portrait)
        case .portraitUpsideDown : self.changeVideoOrientation(orientation: .portraitUpsideDown)
        default: self.changeVideoOrientation(orientation: .portrait)
        }
        
        cameraView.videoPreviewLayer?.frame = cameraView.previewView.frame
        cameraView.videoPreviewView.layer.insertSublayer(self.cameraView.videoPreviewLayer!, above: self.cameraView.videoPreviewView.layer)
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
            self.cameraView.previewView.isHidden = false
            self.cameraView.previewView.contentMode = .scaleAspectFit
            self.cameraView.previewView.backgroundColor = UIColor.black
            self.cameraView.previewView.alpha = 1.0
            self.cameraView.videoPreviewLayer?.isHidden = true

            self.cameraView.previewView.image = image
        }
    }
    
    // MARK: BUTTON HANDLER
    
    //swiftlint:disable force_cast
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        
        if hasCamera {
            if let videoConnection = (captureSession.outputs[0] as? AVCaptureStillImageOutput)?.connection(withMediaType: AVMediaTypeVideo) {
                (captureSession.outputs[0] as? AVCaptureStillImageOutput)?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (buffer, error) -> Void in
                    if let sampleBuffer = buffer {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                        
                        let dataProvider = CGDataProvider(data: imageData! as CFData)
                        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                        
                        let image = self.fixOrientationOfImage(image: UIImage(cgImage: cgImageRef!))
                        /*var imageOrientation: UIImageOrientation
                        
                        switch UIDevice.current.orientation {
                        case .landscapeLeft: imageOrientation = UIImageOrientation.left
                        case .landscapeRight : imageOrientation = UIImageOrientation.right
                        case .portrait : imageOrientation = UIImageOrientation.up
                        case .portraitUpsideDown : imageOrientation = UIImageOrientation.down
                        default: imageOrientation = UIImageOrientation.up
                        }
                        
                        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: imageOrientation)*/
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

    func fixOrientationOfImage(image: UIImage) -> UIImage? {
        if image.imageOrientation == .up {
            return image
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by:  CGFloat(Double.pi / 2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by:  -CGFloat(Double.pi / 2))
        default:
            break
        }
        
        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard let context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue) else {
            return nil
        }
        
        context.concatenate(transform)
        
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        default:
            context.draw(image.cgImage!, in: CGRect(origin: .zero, size: image.size))
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let CGImage = context.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: CGImage)
    }
    
}
