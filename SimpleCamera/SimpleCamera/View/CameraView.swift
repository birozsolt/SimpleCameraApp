//
//  CameraView.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 25/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//
import UIKit
import AVFoundation
import Floaty

/// CameraView protocol used for implementing button actions.
protocol CameraViewProtocol {
    /// Capture button handler touch handler function.
    func captureButtonTapped()
    
    /// Camera switch button touch handler function.
    func toggleCameraButtonTapped()
    
    /// Background touch handler function.
    func backgroundTapped(touchPoint: UITapGestureRecognizer)
}

/// UIView class for setting the camera screen view
class CameraView: UIView {
    /// CameraViewProtocol delegate variable.
    var delegate: CameraViewProtocol?
    
    //MARK: - View variables
    
    /// This variable contains the videoPreview layer, where the camera is showed.
    var videoPreviewView = UIView()
    
    /// The focused part of the videoPreviewView
    var focusPreview = UIView()
    
    /// The layer where we show onion effect, (the previous captured image).
    var onionEffectLayer = UIImageView()
    
    /// This variable initializes the *OrientationViewController*.
    fileprivate var orientationViewController = OrientationViewController()
    
    ///The *VideoPlayerViewController* instance for playing videos.
    fileprivate var videoViewController: VideoPlayerViewController?
    
    ///The settings of the video.
    fileprivate let settings = RenderSettings()
    
    //MARK: - Button variables
    
    /// The capture button variable.
    fileprivate var captureButton = UIButton(type: UIButtonType.custom)
    
    /// The camera switch button variable.
    fileprivate var toggleCameraButton = UIButton(type: UIButtonType.custom)
    
    /// The floating settings button variable.
    fileprivate var floatingSettingsButton = Floaty()
    
    ///The capture device flash mode.
    fileprivate var flashMode = AVCaptureFlashMode.off
    
    //MARK: - Object Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(videoPreviewView)
        addSubview(focusPreview)
        insertSubview(captureButton, aboveSubview: focusPreview)
        insertSubview(toggleCameraButton, aboveSubview: focusPreview)
        insertSubview(orientationViewController.view, aboveSubview: focusPreview)
        addSubview(onionEffectLayer)
        addSubview(floatingSettingsButton)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup funcions for views
    
    /// It setting up camera screen views.
    private func setupViews(){
        
        videoPreviewView.autoPinEdgesToSuperviewEdges()
        videoPreviewView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addFocusPreview)))
        
        onionEffectLayer.autoPinEdgesToSuperviewEdges()
        onionEffectLayer.alpha = 0.5
        onionEffectLayer.isHidden = true
        
        focusPreview.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        focusPreview.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
        focusPreview.autoSetDimensions(to: CGSize(width: 100, height: 100))
        focusPreview.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(moveFocusePreview)))
        focusPreview.isHidden = true
        
        setupOrientationView()
        
        captureButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
        captureButton.autoAlignAxis(toSuperviewAxis: .vertical)
        captureButton.autoSetDimensions(to: CGSize(width: 50, height: 50))
        captureButton.isHidden = false
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        captureButton.layer.cornerRadius = 25
        captureButton.backgroundColor = UIColor.clear
        captureButton.setImage(#imageLiteral(resourceName: "CaptureInactive"), for: .normal)
        captureButton.setImage(#imageLiteral(resourceName: "CaptureActive"), for: .highlighted)
        
        toggleCameraButton.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        toggleCameraButton.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
        toggleCameraButton.autoSetDimensions(to: CGSize(width: 30, height: 30))
        toggleCameraButton.addTarget(self, action: #selector(toggleCamera), for: .touchUpInside)
        toggleCameraButton.backgroundColor = UIColor.clear
        toggleCameraButton.layer.cornerRadius = 15
        toggleCameraButton.setImage(#imageLiteral(resourceName: "CameraRear"), for: .normal)
        
        setupFloatingSettings()
    }
    
    /// It setting up settings button.
    private func setupFloatingSettings(){
        floatingSettingsButton.autoCloseOnTap = false
        floatingSettingsButton.openAnimationType = .fade
        floatingSettingsButton.animationSpeed = 0.01
        floatingSettingsButton.friendlyTap = true
        floatingSettingsButton.itemSpace = 1
        floatingSettingsButton.buttonColor = .darkGray
        floatingSettingsButton.plusColor = .white
        floatingSettingsButton.itemTitleColor = .lightGray
        floatingSettingsButton.itemButtonColor = .darkGray
        floatingSettingsButton.overlayColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        floatingSettingsButton.addItem("Flash Mode", icon: #imageLiteral(resourceName: "FlashOff"), handler: flashHandler(_:))
        floatingSettingsButton.addItem("Onion Effect", icon: #imageLiteral(resourceName: "OnionSkinOff"), handler: onionEffectHandler(_:))
        floatingSettingsButton.addItem("Orientation Assist", icon: #imageLiteral(resourceName: "OrientationOff"), handler: orientationHandler(_:))
        floatingSettingsButton.addItem("Time Lapse Builder", icon: #imageLiteral(resourceName: "TimeLapse"), handler: timeLapseHandler(_:))
        floatingSettingsButton.addItem("Video Player", icon: #imageLiteral(resourceName: "VideoPlayer"), handler: videoPlayerHandler(_:))
    }
    
    /// It setting up the orientation view.
    private func setupOrientationView(){
        orientationViewController.view.autoCenterInSuperview()
        orientationViewController.view.isHidden = true
    }
    
    //MARK: - Button image changer functions
    
    /**
     It change the camera switch button image.
     - parameter image: Change camera switch button to *image*.
     */
    private func changeCameraImage(to image: UIImage){
        toggleCameraButton.setImage(image, for: .normal)
    }
    
    /**
     It animate the camera switch button image.
     - parameter image: The result image after the animation finished.
     */
    func flipCameraSwitchButton(to image: UIImage){
        UIView.transition(with: toggleCameraButton,
                          duration: 0.3,
                          options: UIViewAnimationOptions.transitionFlipFromLeft,
                          animations: nil,
                          completion: { (finished) -> Void in
                            self.changeCameraImage(to: image)
        })
    }
    
    /// Methode for moving the focus preview
    func moveFocusePreview(gesture: UIPanGestureRecognizer){
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        var velocityX : CGFloat = 0
        let gestureLocation = gesture.location(in: videoPreviewView)
        if gesture.state == .ended {
            velocityX = gesture.velocity(in: videoPreviewView).x * 0.4
        }
        
        let animationDuration = (abs(velocityX) * 0.0002) + 0.2
        
        UIView.animate(withDuration: TimeInterval(animationDuration), delay: 0, options: .curveLinear, animations: {
            
            if gestureLocation.x >= 60 && gestureLocation.y >= 60 && gestureLocation.x <= self.videoPreviewView.frame.size.width - 60 && gestureLocation.y <= self.videoPreviewView.frame.size.height - 60 {
                self.focusPreview.center = gestureLocation
            }

            if gestureLocation.x < 60 && gestureLocation.y < 60 {
                self.focusPreview.center = CGPoint(x: 60, y: 60)
            } else if gestureLocation.x < 60 {
                self.focusPreview.center = CGPoint(x: 60, y: gestureLocation.y)
            } else if gestureLocation.y < 60 {
                self.focusPreview.center = CGPoint(x: gestureLocation.x, y: 60)
            }
            
            if gestureLocation.x > self.videoPreviewView.frame.size.width - 60 && gestureLocation.y > self.videoPreviewView.frame.size.height - 60 {
                self.focusPreview.center = CGPoint(x: self.videoPreviewView.frame.size.width - 60, y: self.videoPreviewView.frame.size.height - 60 )
            } else if gestureLocation.x > self.videoPreviewView.frame.size.width - 60 {
                self.focusPreview.center = CGPoint(x: self.videoPreviewView.frame.size.width - 60, y: gestureLocation.y)
            } else if gestureLocation.y > self.videoPreviewView.frame.size.height - 60 {
                self.focusPreview.center = CGPoint(x: gestureLocation.x, y: self.videoPreviewView.frame.size.height - 60)
            }
            
            if gestureLocation.x < 60 && gestureLocation.y > self.videoPreviewView.frame.size.height - 60 {
                self.focusPreview.center = CGPoint(x: 60, y: self.videoPreviewView.frame.size.height - 60)
            } else if gestureLocation.x > self.videoPreviewView.frame.size.width - 60 && gestureLocation.y < 60 {
                self.focusPreview.center = CGPoint(x: self.videoPreviewView.frame.size.width - 60, y: 60)
            }
        })
    }
    
    // MARK: - Button touch handler functions
    
    /**
     It is called after touching the capture button.
     - Implemented in the class which adopted *CameraViewProtocol*.
     */
    func capturePhoto() {
        delegate?.captureButtonTapped()
    }
    
    /**
     It is called after touching the camera switch button.
     - Implemented in the class which adopted *CameraViewProtocol*.
     */
    func toggleCamera(){
        delegate?.toggleCameraButtonTapped()
    }
    
    /**
     It is called after touching the camera background view.
     - Implemented in the class which adopted *CameraViewProtocol*.
     */
    func addFocusPreview(touchPoint: UITapGestureRecognizer) {
        delegate?.backgroundTapped(touchPoint: touchPoint)
    }
}

extension CameraView: FloatyDelegate {
    // MARK: - Floating button item touch handlers
    /**
     It is called after touching the Flash Mode button.
     */
    fileprivate func flashHandler(_ item: FloatyItem) -> Void {
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
            ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.noCamerasAvailable)
            return
        }
        
        switch self.flashMode {
        case .on:
            self.flashMode = .off
            item.titleColor = .lightGray
            item.icon = #imageLiteral(resourceName: "FlashOff")
        case .auto:
            self.flashMode = .on
            item.titleColor = .white
            item.icon = #imageLiteral(resourceName: "FlashOn")
        case .off:
            self.flashMode = .auto
            item.titleColor = .white
            item.icon = #imageLiteral(resourceName: "FlashAuto")
        }
        
        if device.hasFlash {
            do {
                try device.lockForConfiguration()
                device.flashMode = self.flashMode
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    /**
     It is called after touching the Onion Effect button.
     */
    fileprivate func onionEffectHandler(_ item: FloatyItem) -> Void {
        if onionEffectLayer.isHidden {
            item.icon = #imageLiteral(resourceName: "OnionSkinOn")
            item.itemBackgroundColor = .lightGray
            item.titleColor = .white
            onionEffectLayer.isHidden = false
            if onionEffectLayer.image == nil {
                ErrorMessage.sharedInstance.show(LocalizedKeys.titleWarning, message: LocalizedKeys.onionEffectLayerError)
            }
        } else {
            item.icon = #imageLiteral(resourceName: "OnionSkinOff")
            item.itemBackgroundColor = .darkGray
            item.titleColor = .lightGray
            onionEffectLayer.isHidden = true
        }
    }
    
    /**
     It is called after touching the Orientation Assist button.
     */
    fileprivate func orientationHandler(_ item: FloatyItem) -> Void {
        if item.icon == #imageLiteral(resourceName: "OrientationOff") {
            orientationViewController.startMotionUpdate()
            orientationViewController.view.isHidden = false
            item.icon = #imageLiteral(resourceName: "OrientationOn")
            item.itemBackgroundColor = .lightGray
            item.titleColor = .white
            
        } else {
            orientationViewController.stopMotionUpdate()
            orientationViewController.view.isHidden = true
            item.icon = #imageLiteral(resourceName: "OrientationOff")
            item.itemBackgroundColor = .darkGray
            item.titleColor = .lightGray
        }
    }
    
    /**
     It is called after touching the Time Lapse Builder button.
     */
    fileprivate func timeLapseHandler(_ item: FloatyItem) -> Void {
        floatingSettingsButton.close()
        if imageArray.isEmpty {
            ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.timeLapseBuildError)
            return
        }
        let progressHUD = ProgressHUD()
        progressHUD.setTextLabel("Building your timelapse...")
        progressHUD.setProgress(0, animated: true)
        DispatchQueue.main.async {
            progressHUD.show()
        }
        
        let timeLapseBuilder = TimeLapseBuilder(renderSettings: settings)
        timeLapseBuilder.render(
            {(progress: Progress) in
                let progressPercentage = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                progressHUD.setProgress(progressPercentage, animated: true)
        },  completion: {
            progressHUD.dismiss()
        })
        progressHUD.dismiss()
        
    }
    
    /**
     It is called after touching the Video Player button.
     */
    fileprivate func videoPlayerHandler(_ item: FloatyItem) -> Void {
        guard let videoUrl = settings.outputURL, !Platform.isSimulator else {
            ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.videoPlayerError)
            return
        }
        floatingSettingsButton.close()
        videoViewController = VideoPlayerViewController(videoUrl: videoUrl)
        gNavigationViewController?.pushViewController(videoViewController!, animated: true)
    }
    
    // MARK: - FloatyDelegate methodes
    
    func floatyClosed(_ floaty: Floaty) {
        
    }
    
    func floatyOpened(_ floaty: Floaty) {
        
    }
    
    func floatyDidOpen(_ floaty: Floaty) {
        
    }
    
    func floatyDidClose(_ floaty: Floaty) {
        
    }
    
    func floatyWillOpen(_ floaty: Floaty) {
        
    }
    
    func floatyWillClose(_ floaty: Floaty) {
        
    }
    
    func emptyFloatySelected(_ floaty: Floaty) {
        
    }
}
