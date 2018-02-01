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
    fileprivate var captureSession : AVCaptureSession?
    
    ///A capture output for recording still images.
    fileprivate var photoOutput: AVCaptureStillImageOutput?
    
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
    
    override var prefersStatusBarHidden: Bool {return true}
    
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
        guard let captureSession = captureSession, !captureSession.isRunning else { return }
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let captureSession = captureSession, captureSession.isRunning else { return }
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
            captureSession = AVCaptureSession()
        }
        
        /**
         Configure the capture device for *captureSession*.
         - throws: *CameraControllerError* if no camera available.
         */
        func configureCaptureDevices() throws {
            let session = AVCaptureSession()
            session.sessionPreset = AVCaptureSessionPresetiFrame960x540
            
            guard let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo), !devices.isEmpty else {
                isCameraAlreadySetUp = false
                throw CameraControllerError.noCamerasAvailable
            }
            isCameraAlreadySetUp = true
            for device in devices {
                let device = device as! AVCaptureDevice
                if device.position == .front {
                    frontCamera = device
                }
                
                if device.position == .back {
                    rearCamera = device
                    
                    try device.lockForConfiguration()
                    device.focusMode = .continuousAutoFocus
                    device.unlockForConfiguration()
                }
            }
        }
        
        /**
         Configure the capture input that provides media from capture devices to the *captureSession*.
         - throws: *CameraControllerError* if no capture session or no camera found.
         */
        func configureDeviceInputs() throws {
            guard let captureSession = captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            if let rearCamera = rearCamera {
                rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(rearCameraInput!) { captureSession.addInput(rearCameraInput!) }
                
                currentCameraPosition = .rear
            }
                
            else if let frontCamera = frontCamera {
                frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(frontCameraInput!) { captureSession.addInput(frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }
                
                currentCameraPosition = .front
            }
                
            else { throw CameraControllerError.noCamerasAvailable }
        }
        
        /**
         Configure a capture output for recording still images.
         - throws: *CameraControllerError* if no capture session found.
         */
        func configurePhotoOutput() throws {
            guard let captureSession = captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            photoOutput = AVCaptureStillImageOutput()
            photoOutput!.isHighResolutionStillImageOutputEnabled = true
            photoOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            if captureSession.canAddOutput(photoOutput) { captureSession.addOutput(photoOutput) }
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
    
    //MARK: - Display camera preview methode
    
    /**
     Displays the video preview from capture session.
     - throws: *CameraControllerError* if no capture session found.
     */
    private func displayPreview() throws {
        guard let captureSession = captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
        
        cameraView.videoPreviewView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        cameraView.onionEffectLayer.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        videoPreviewLayer?.frame = CGRect(origin: CGPoint.zero, size: cameraView.videoPreviewView.bounds.size)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraView.onionEffectLayer.contentMode = .scaleAspectFill
        cameraView.videoPreviewView.layer.insertSublayer(videoPreviewLayer!, above: cameraView.videoPreviewView.layer)
    }
    
    //MARK: - Camera Switch methodes
    
    /**
     Switch between front and rear cameras.
     - throws: *CameraControllerError* if no capture session found.
     */
    fileprivate func switchCameras() throws {
        guard let currentCameraPosition = currentCameraPosition, let captureSession = captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        captureSession.beginConfiguration()
        
        /**
         Switch to front camera.
         - throws: *CameraControllerError* if no capture session or no capture device found.
         */
        func switchToFrontCamera() throws {
            guard let inputs = captureSession.inputs as? [AVCaptureInput], let rearCameraInput = rearCameraInput, inputs.contains(rearCameraInput),
                let frontCamera = frontCamera else { throw CameraControllerError.invalidOperation }
            
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
            guard let inputs = captureSession.inputs as? [AVCaptureInput], let frontCameraInput = frontCameraInput, inputs.contains(frontCameraInput),
                let rearCamera = rearCamera else { throw CameraControllerError.invalidOperation }
            
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
            cameraView.flipCameraSwitchButton(to: #imageLiteral(resourceName: "CameraFront"))
            try switchToRearCamera()
        case .rear:
            try switchToFrontCamera()
            cameraView.flipCameraSwitchButton(to: #imageLiteral(resourceName: "CameraRear"))
        }
        captureSession.commitConfiguration()
    }
}


// MARK: - CameraViewProtocol extension

extension CameraViewController: CameraViewProtocol {
    
    func captureButtonTapped() {
        captureImage{ (image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            imageArray.append(image)
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            self.cameraView.onionEffectLayer.image = image
        }
    }
    
    //swiftlint:disable force_cast
    /**
     Capture an image from *captureSession*.
     - parameter completion: Returns the image if succes otherwise an error.
     - parameter image: Contains the image if the capture was succes, otherwise `nil`.
     - parameter error: Contains an error if capture session is missing, otherwise `nil`.
     */
    func captureImage(completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        
        if isCameraAlreadySetUp {
            if let videoConnection = photoOutput?.connection(withMediaType: AVMediaTypeVideo){ /*(captureSession.outputs[0] as? AVCaptureStillImageOutput)?*/
                videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
                photoOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (buffer, error) -> Void in /*(captureSession.outputs[0] as? AVCaptureStillImageOutput)?*/
                    if let sampleBuffer = buffer {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                        
                        let dataProvider = CGDataProvider(data: imageData! as CFData)
                        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                        
                        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
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
            ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.noCamerasAvailable)
        }
    }
}
