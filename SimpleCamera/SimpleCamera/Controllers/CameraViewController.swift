//
//  CameraViewController.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 25/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit
import PureLayout
import AVFoundation
import Photos
/**
 Camera position types.
 
 - front: Front camera.
 - rear: Rear camera.
 */
fileprivate enum CameraPosition {
    case front
    case rear
}

/**
 CameraCotroller error types.
 
 - captureSessionAlreadyRunning: The capture session already running.
 - captureSessionIsMissing: The capture session not found.
 - inputsAreInvalid: No valid inputs avaible for capture device.
 - invalidOperation: Invalid Operation occured.
 - noCamerasAvailable: No capture device found.
 - unknown: Unknown error.
 */
enum CameraControllerError: Swift.Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case unknown
}

///UIViewController class for managing the camera screen.
class CameraViewController: UIViewController {
    
    ///The view that the *CameraViewController* manages.
    fileprivate var cameraView = CameraView(frame: CGRect.zero)
    
    ///The layer that is used to display video as it is being captured by an input device
    fileprivate var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    ///An object that manages the capture activity and coordinates the flow of data from input devices to capture outputs.
    fileprivate var captureSession = AVCaptureSession()
    
    ///A capture output for recording still images.
    fileprivate var photoOutput: AVCapturePhotoOutput?
    
    ///The capture device that provides video input for *captureSession* and offers controls for hardware-specific capture features.
    fileprivate var captureDevice: AVCaptureDevice?
    
    ///The object used for front camera device
    fileprivate var frontCamera: AVCaptureDevice?
    
    ///A capture input that provides media from the *frontCamera* to a capture session.
    fileprivate var frontCameraInput: AVCaptureDeviceInput?
    
    ///The object used for rear camera device
    fileprivate var rearCamera: AVCaptureDevice?
    
    ///A capture input that provides media from the *rearCamera* to a capture session.
    fileprivate var rearCameraInput: AVCaptureDeviceInput?
    
    ///A bool value indicates that the camera is already set up (**true**) or not (**false**).
    fileprivate var isCameraAlreadySetUp = false
    
    ///The currently active camera position
    fileprivate var currentCameraPosition: CameraPosition?
    
    fileprivate var sessionQueue = DispatchQueue(label: "SessionQueue")
    
    override var prefersStatusBarHidden: Bool {return true}
    
    fileprivate var motionData: MotionData?
    
    // MARK: View Lifecycle
    
    override func loadView() {
        view = cameraView
        cameraView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare(completionHandler: { (error) in
            do {
                try self.displayPreview()
            } catch {
                ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.noCamerasAvailable)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !captureSession.isRunning else { return }
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
    }
    
    //MARK: - Configuring camera for capture.
    
    /**
     Prepare the the application to display the video preview.
     - parameter completionHandler: Returns `nil` if succes otherwise an error.
     - parameter error: Contains an error if capture session is missing, otherwise `nil`.
     */
    private func prepare(completionHandler: @escaping (_ error: Error?) -> Void) {
        
        /// Initiate the *captureSession* object.
        func createCaptureSession() {
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
        }
        
        /**
         Configure the capture device for *captureSession*.
         - throws: *CameraControllerError* if no camera available.
         */
        func configureCaptureDevices() throws {
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
            let devices = deviceDiscoverySession.devices
            if devices.isEmpty {
                isCameraAlreadySetUp = false
                throw CameraControllerError.noCamerasAvailable
            }
            isCameraAlreadySetUp = true
            for device in devices {
                if device.position == .front {
                    frontCamera = device
                }
                
                if device.position == .back {
                    rearCamera = device
                }
            }
        }
        
        /**
         Configure the capture input that provides media from capture devices to the *captureSession*.
         - throws: *CameraControllerError* if no capture session or no camera found.
         */
        func configureDeviceInputs() throws {
            guard captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
            
            if let rearCamera = rearCamera {
                rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                if captureSession.canAddInput(rearCameraInput!) {
                    captureSession.addInput(rearCameraInput!)
                } else {
                    throw CameraControllerError.inputsAreInvalid
                }
                currentCameraPosition = .rear
            } else if let frontCamera = frontCamera {
                frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                if captureSession.canAddInput(frontCameraInput!) {
                    captureSession.addInput(frontCameraInput!)
                } else {
                    throw CameraControllerError.inputsAreInvalid
                }
                currentCameraPosition = .front
            }
            else {
                throw CameraControllerError.noCamerasAvailable
            }
        }
        
        /**
         Configure a capture output for recording still images.
         - throws: *CameraControllerError* if no capture session found.
         */
        func configurePhotoOutput() throws {
            guard captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
            
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            photoOutput?.isHighResolutionCaptureEnabled = true
            
            if captureSession.canAddOutput(photoOutput!) {
                captureSession.addOutput(photoOutput!)
            }
            captureSession.startRunning()
        }
        
        sessionQueue.async {
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
    
    //MARK: - Display camera preview methode
    
    /**
     Displays the video preview from capture session.
     - throws: *CameraControllerError* if no capture session found.
     */
    private func displayPreview() throws {
        guard captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        cameraView.videoPreviewView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        cameraView.onionEffectLayer.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        videoPreviewLayer?.frame = CGRect(origin: CGPoint.zero, size: cameraView.videoPreviewView.bounds.size)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraView.onionEffectLayer.contentMode = .scaleAspectFill
        cameraView.videoPreviewView.layer.insertSublayer(videoPreviewLayer!, above: cameraView.videoPreviewView.layer)
    }
    
    //MARK: - Camera Switch methodes
    
    /**
     Switch between front and rear cameras.
     - throws: *CameraControllerError* if no capture session found.
     */
    fileprivate func switchCameras() throws {
        guard let currentCameraPosition = currentCameraPosition, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        captureSession.beginConfiguration()
        
        /**
         Switch to front camera.
         - throws: *CameraControllerError* if no capture session or no capture device found.
         */
        func switchToFrontCamera() throws {
            let inputs = captureSession.inputs
            guard let rearCameraInput = rearCameraInput, inputs.contains(rearCameraInput),
                let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(frontCameraInput!) {
                captureSession.addInput(frontCameraInput!)
                
                self.currentCameraPosition = .front
                captureDevice = frontCamera
            } else {
                throw CameraControllerError.invalidOperation
            }
        }
        
        /**
         Switch rear camera.
         - throws: `CameraControllerError` if no capture session or no capture device found.
         */
        func switchToRearCamera() throws {
            let inputs = captureSession.inputs
            guard let frontCameraInput = frontCameraInput, inputs.contains(frontCameraInput), let rearCamera = rearCamera else {
                throw CameraControllerError.invalidOperation
            }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(rearCameraInput!) {
                captureSession.addInput(rearCameraInput!)
                
                self.currentCameraPosition = .rear
                captureDevice = rearCamera
            }
                
            else { throw CameraControllerError.invalidOperation }
        }
        
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()
            DispatchQueue.main.async {
                self.cameraView.flipCameraSwitchButton(to: #imageLiteral(resourceName: "CameraFront"))
            }
            
        case .rear:
            try switchToFrontCamera()
            DispatchQueue.main.async {
                self.cameraView.flipCameraSwitchButton(to: #imageLiteral(resourceName: "CameraRear"))
            }
        }
        captureSession.commitConfiguration()
    }
}


// MARK: - CameraViewProtocol extension

extension CameraViewController: CameraViewProtocol {
    
    func captureButtonTapped(motionData: MotionData) {
        sessionQueue.async {
            self.motionData = motionData
            self.captureImage()
        }
    }
    
    //swiftlint:disable force_cast
    /**
     Capture an image from *captureSession*.
     - parameter completion: Returns the image if succes otherwise an error.
     - parameter image: Contains the image if the capture was succes, otherwise `nil`.
     - parameter error: Contains an error if capture session is missing, otherwise `nil`.
     */
    func captureImage(/*completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void*/) {
        
        guard captureSession.isRunning else { return }
        
        if isCameraAlreadySetUp {
            if let videoConnection = photoOutput?.connection(with: AVMediaType.video){ /*(captureSession.outputs[0] as? AVCaptureStillImageOutput)?*/
                videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
                let settings = cameraView.getFlashSettings()
                photoOutput?.capturePhoto(with: settings, delegate: self)
            } else {
                print("Video capture problem")
            }
        }
    }//swiftlint:enable force_cast
    
    func toggleCameraButtonTapped() {
        sessionQueue.async {
            do {
                try self.switchCameras()
            }
            catch {
                ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.noCamerasAvailable)
            }
        }
    }
    
    func backgroundTapped(touchPoint: UITapGestureRecognizer) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.noCamerasAvailable)
            return
        }
        
        let screenSize = self.view.bounds.size
        let focusPoint = CGPoint(x: touchPoint.location(in: self.view).x / screenSize.width,
                                 y: touchPoint.location(in: self.view).y / screenSize.height)
        
        let layer = CAShapeLayer()
        let x = touchPoint.location(in: self.view).x - 50
        let y = touchPoint.location(in: self.view).y - 50
        layer.path = CGPath(rect: CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: 100, height: 100)), transform: nil)
        layer.strokeColor = UIColor.red.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 1.0
        
        if (cameraView.videoPreviewView.layer.sublayers?.count)! > 1 {
            cameraView.videoPreviewView.layer.sublayers?.removeLast()
        }
        cameraView.videoPreviewView.layer.insertSublayer(layer, above: videoPreviewLayer)
        do {
            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
            }
            device.unlockForConfiguration()
        }
        catch {
            ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.noCamerasAvailable)
        }
        cameraView.focusPreview.isHidden = false
        cameraView.focusPreview.backgroundColor = .green
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.noCamerasAvailable)
            return
        }
        let image = UIImage(data: imageData)
        
        image!.motionData = motionData
        PhotoAlbum.sharedInstance.saveImage(image: image!)
        DispatchQueue.main.async {
            self.cameraView.onionEffectLayer.image = image
        }
    }
}
