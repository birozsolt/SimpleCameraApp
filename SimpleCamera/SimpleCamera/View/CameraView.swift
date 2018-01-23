//
//  CameraView.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 25/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//
import UIKit

/// CameraView protocol used for implementing button actions.
protocol CameraViewProtocol {
    /// Capture button handler touch handler function.
    func captureButtonTapped()
    
    /// Camera switch button touch handler function.
    func toggleCameraButtonTapped()
}

/// UIView class for setting the camera screen view
class CameraView: UIView {
    /// CameraViewProtocol delegate variable.
    var delegate: CameraViewProtocol?
    
    //MARK: - View variables
    
    /// The background view of the *CameraView*.
    static var previewView = UIImageView()
    
    /// This variable contains the videoPreview layer, where the camera is showed.
    var videoPreviewView = UIView()
    
    /// The layer where we show onion effect, (the previous captured image).
    static var onionEffectLayer = UIImageView()
    
    /// This variable initializes the *SettingsViewController*.
    static var settingsViewController = SettingsViewController()
    
    /// This variable initializes the *OrientationViewController*.
    static var orientationViewController = OrientationViewController()
    
    //MARK: - Button variables
    
    /// The capture button variable.
    private var captureButton = UIButton(type: UIButtonType.custom)
    
    /// The camera switch button variable.
    private var toggleCameraButton = UIButton(type: UIButtonType.custom)
    
    /// The settings button variable.
    private var toggleSettingsButton = UIView()
    
    //MARK: - Settings button variables
    
    /// The *toggleSettingsButton* arrow view component.
    private static var settingsButtonArrow = UIImageView()
    
    /// The *toggleSettingsButton* grid view component.
    private static var settingsButtonGridView = UIImageView()
    
    //MARK: - Setting menu state variables
    
    /**
     Setting menu current state
     - default state: *.close*.
     */
    static var isSettingsOpened : SettingMenuState = .close
    
    /**
     Settings menu state.
     
     - open: Opened state.
     - close: Closed state.
     */
    enum SettingMenuState {
        case open, close, undefined
    }
    
    //MARK: - Object Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(CameraView.previewView)
        insertSubview(captureButton, aboveSubview: CameraView.previewView)
        insertSubview(toggleCameraButton, aboveSubview: CameraView.previewView)
        insertSubview(toggleSettingsButton, aboveSubview: CameraView.previewView)
        addSubview(CameraView.settingsViewController.view)
        insertSubview(CameraView.orientationViewController.view, aboveSubview: CameraView.previewView)
        insertSubview(videoPreviewView, belowSubview: CameraView.previewView)
        insertSubview(CameraView.onionEffectLayer, belowSubview: CameraView.previewView)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup funcions for views
    
    /// It setting up camera screen views.
    private func setupViews(){
        CameraView.previewView.autoPinEdgesToSuperviewEdges()
        CameraView.previewView.isHidden = true
        CameraView.previewView.alpha = 0.0
        CameraView.previewView.backgroundColor = UIColor.black
        
        videoPreviewView.autoPinEdgesToSuperviewEdges()
        
        CameraView.onionEffectLayer.autoPinEdgesToSuperviewEdges()
        CameraView.onionEffectLayer.alpha = 0.5
        CameraView.onionEffectLayer.isHidden = true
        
        setupSettingsView()
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
        
        setupSettingsButton()
    }
    
    /// It setting up the settings button components
    private func setupSettingsButton(){
        CameraView.settingsButtonGridView = UIImageView(image: #imageLiteral(resourceName: "SettingView"))
        CameraView.settingsButtonArrow.image = #imageLiteral(resourceName: "ArrowRight")
        
        toggleSettingsButton.autoAlignAxis(.horizontal, toSameAxisOf: captureButton)
        toggleSettingsButton.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        toggleSettingsButton.autoSetDimensions(to: CGSize(width: 40, height: 30))
        toggleSettingsButton.backgroundColor = UIColor.clear
        toggleSettingsButton.addSubview(CameraView.settingsButtonArrow)
        toggleSettingsButton.addSubview(CameraView.settingsButtonGridView)
        toggleSettingsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleSettings)))
        
        CameraView.settingsButtonArrow.autoPinEdge(.left, to: .left, of: toggleSettingsButton)
        CameraView.settingsButtonArrow.autoPinEdge(.bottom, to: .bottom, of: toggleSettingsButton)
        CameraView.settingsButtonArrow.autoPinEdge(.top, to: .top, of: toggleSettingsButton)
        CameraView.settingsButtonArrow.autoSetDimension(.width, toSize: 10)
        CameraView.settingsButtonArrow.contentMode = .scaleAspectFill
        
        CameraView.settingsButtonGridView.autoPinEdge(.left, to: .right, of: CameraView.settingsButtonArrow)
        CameraView.settingsButtonGridView.autoPinEdge(.bottom, to: .bottom, of: toggleSettingsButton)
        CameraView.settingsButtonGridView.autoPinEdge(.top, to: .top, of: toggleSettingsButton)
        CameraView.settingsButtonGridView.autoSetDimension(.width, toSize: 30)
    }
    
    /// It setting up the settings menu.
    private func setupSettingsView() {
        CameraView.settingsViewController.view.autoPinEdge(toSuperviewEdge: .left)
        CameraView.settingsViewController.view.autoPinEdge(.bottom, to: .top, of: captureButton, withOffset: -20)
        CameraView.settingsViewController.view.autoSetDimensions(to: CGSize(width: self.bounds.width, height: 160))
        CameraView.settingsViewController.view.isHidden = true
    }
    
    /// It setting up the orientation view.
    private func setupOrientationView(){
         CameraView.orientationViewController.view.autoCenterInSuperview()
         CameraView.orientationViewController.view.isHidden = true
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
     It change the setting button arrow image.
     - parameter image: Change settings button arrow to *image*.
     */
    private static func changeArrowImage(to image: UIImage){
        settingsButtonArrow.image = image
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
    
    // MARK: - Button touch handler functions
    
    /**
     It is called after touching the capture button.
     - Implemented in the class which adopted *CameraViewProtocol*.
     */
    func capturePhoto() {
        if CameraView.isSettingsOpened != .close {
            CameraView.hideSettings()
        }
        delegate?.captureButtonTapped()
    }
    
    /**
     It is called after touching the camera switch button.
     - Implemented in the class which adopted *CameraViewProtocol*.
     */
    func toggleCamera(){
        if CameraView.isSettingsOpened != .close {
            CameraView.hideSettings()
        }
        delegate?.toggleCameraButtonTapped()
    }
    
    /// It is called after touching the settings button.
    func toggleSettings() {
        if CameraView.isSettingsOpened == .close {
            CameraView.showSettings()
        } else {
            CameraView.hideSettings()
        }
    }
    
    // MARK: - Setting button and view animation functions
    
    /// Show the setting menu.
    private static func showSettings(){
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            settingsViewController.view.isHidden = false
            settingsViewController.view.frame = CGRect(x: 0, y: settingsViewController.view.frame.origin.y, width: previewView.frame.width, height: settingsViewController.view.frame.height)
            animateSettingsButton(toState: .open)
            isSettingsOpened = .open
        })
    }

    /// Hide the setting menu.
    static func hideSettings(){
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            settingsViewController.view.frame = CGRect(x: 0 - previewView.bounds.width, y: settingsViewController.view.frame.origin.y, width: previewView.frame.width, height: settingsViewController.view.frame.height)
            if isSettingsOpened != .undefined {
                animateSettingsButton(toState: .close)
            }
            isSettingsOpened = .close
        }) { (finished) in
            CameraView.settingsViewController.view.isHidden = true
        }
    }

    /**
     Animate the settings button.
     
     - parameter state: The state for opening or closing animation.
     - **.open** will animate the settingsView to opened state.
     - **.close** will animate the settingsView to closed state.
     */
    private static func animateSettingsButton(toState state: SettingMenuState) {
        switch state {
        case .open:
            changeArrowImage(to:#imageLiteral(resourceName: "ArrowLeft"))
            settingsButtonArrow.moveXCoordinate(with: 30)
            settingsButtonGridView.moveXCoordinate(with: -10)
        case .close:
            changeArrowImage(to:#imageLiteral(resourceName: "ArrowRight"))
            settingsButtonArrow.moveXCoordinate(with: -30)
            settingsButtonGridView.moveXCoordinate(with: 10)
        case .undefined:
            break
        }
    }
}
