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
    public var delegate: CameraViewProtocol?
    
    //MARK: - View variables
    
    /// The background view of the *CameraView*.
    public var previewView = UIImageView()
    
    /// This variable contains the videoPreview layer, where the camera is showed.
    public var videoPreviewView = UIView()
    
    /// This variable initializes the *SettingsViewController*.
    public var settingsViewController = SettingsViewController()
    
    /// This variable initializes the *OrientationViewController*.
    public var orientationViewController = OrientationViewController()
    
    //MARK: - Button variables
    
    /// The capture button variable.
    private var captureButton = UIButton(type: UIButtonType.custom)
    
    /// The camera switch button variable.
    private var toggleCameraButton = UIButton(type: UIButtonType.custom)
    
    /// The settings button variable.
    private var toggleSettingsButton = UIView()
    
    //MARK: - Settings button variables
    
    /// The *toggleSettingsButton* arrow view component.
    private var settingsButtonArrow = UIImageView()
    
    /// The *toggleSettingsButton* grid view component.
    private var settingsButtonGridView = UIImageView()
    
    /// The *settingsButtonArrow* frame.
    private var arrowFrame = CGRect()
    
    /// The *settingsButtonGridView* frame.
    private var gridFrame = CGRect()
    
    //MARK: - Setting menu state variables
    
    /**
     Setting menu current state
        - default state: *.close*.
     */
    public var isSettingsOpened : SettingMenuState = .close
    
    /**
     Settings menu state.
     
     - open: Opened state.
     - close: Closed state.
     */
    enum SettingMenuState {
        case open, close
    }
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(previewView)
        self.insertSubview(captureButton, aboveSubview: previewView)
        self.insertSubview(toggleCameraButton, aboveSubview: previewView)
        self.insertSubview(toggleSettingsButton, aboveSubview: previewView)
        self.insertSubview(settingsViewController.view, aboveSubview: previewView)
        self.insertSubview(orientationViewController.view, aboveSubview: previewView)
        self.insertSubview(videoPreviewView, belowSubview: previewView)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup funcions for views
    
    /// It setting up camera screen views.
    func setupViews(){
        previewView.autoPinEdgesToSuperviewEdges()
        previewView.isHidden = true
        previewView.alpha = 0.0
        previewView.backgroundColor = UIColor.black
        
        videoPreviewView.autoPinEdgesToSuperviewEdges()
        
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
    func setupSettingsButton(){
        settingsButtonGridView = UIImageView(image: #imageLiteral(resourceName: "SettingView"))
        settingsButtonArrow.image = #imageLiteral(resourceName: "ArrowRight")
        
        toggleSettingsButton.autoAlignAxis(.horizontal, toSameAxisOf: captureButton)
        toggleSettingsButton.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        toggleSettingsButton.autoSetDimensions(to: CGSize(width: 40, height: 30))
        toggleSettingsButton.backgroundColor = UIColor.clear
        toggleSettingsButton.addSubview(settingsButtonArrow)
        toggleSettingsButton.addSubview(settingsButtonGridView)
        toggleSettingsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleSettings)))
        
        settingsButtonArrow.autoPinEdge(.left, to: .left, of: toggleSettingsButton)
        settingsButtonArrow.autoPinEdge(.bottom, to: .bottom, of: toggleSettingsButton)
        settingsButtonArrow.autoPinEdge(.top, to: .top, of: toggleSettingsButton)
        settingsButtonArrow.autoSetDimension(.width, toSize: 10)
        settingsButtonArrow.contentMode = .scaleAspectFill
        
        settingsButtonGridView.autoPinEdge(.left, to: .right, of: settingsButtonArrow)
        settingsButtonGridView.autoPinEdge(.bottom, to: .bottom, of: toggleSettingsButton)
        settingsButtonGridView.autoPinEdge(.top, to: .top, of: toggleSettingsButton)
        settingsButtonGridView.autoSetDimension(.width, toSize: 30)
        
        arrowFrame = self.convert(settingsButtonArrow.frame, from: toggleSettingsButton)
        gridFrame = self.convert(settingsButtonGridView.frame, from: toggleSettingsButton)
    }
    
    /// It setting up the settings menu.
    func setupSettingsView() {
        settingsViewController.view.autoPinEdge(toSuperviewEdge: .left)
        settingsViewController.view.autoPinEdge(.bottom, to: .top, of: captureButton, withOffset: -20)
        settingsViewController.view.autoSetDimensions(to: CGSize(width: self.previewView.frame.size.width, height: 160))
        settingsViewController.view.isHidden = true
    }
    
    /// It setting up the orientation view.
    func setupOrientationView(){
        orientationViewController.view.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
        orientationViewController.view.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        orientationViewController.view.autoSetDimensions(to: CGSize(width: 100 , height: 100))
    }
    
    //MARK: - Button image changer functions
    
    /**
     It change the camera switch button image.
     - parameter image: Change camera switch button to *image*.
     */
    func changeCameraImage(to image: UIImage){
        toggleCameraButton.setImage(image, for: .normal)
    }
    
    /**
     It change the setting button arrow image.
     - parameter image: Change settings button arrow to *image*.
     */
    func changeArrowImage(to image: UIImage){
        settingsButtonArrow.image = image
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
    
    /// It is called after touching the settings button.
    func toggleSettings() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            if self.isSettingsOpened == .close {
                self.showSettings()
                self.isSettingsOpened = .open
            } else {
                self.hideSettings()
                self.isSettingsOpened = .close
            }
        }) { (finished) in
            if self.isSettingsOpened == .close {
                self.settingsViewController.view.isHidden = true
                self.changeArrowImage(to: #imageLiteral(resourceName: "ArrowRight"))
            } else {
                self.settingsViewController.view.isHidden = false
                self.changeArrowImage(to: #imageLiteral(resourceName: "ArrowLeft"))
            }
        }
    }
    
    // MARK: - Setting button and view animation functions
    
    /// Show the setting menu.
    func showSettings(){
        settingsViewController.view.frame = CGRect(x: 0,
                                                   y: previewView.frame.size.height - 250,
                                                   width: previewView.frame.size.width,
                                                   height: 160)
        settingsViewController.view.isHidden = false
        animateSettingsButton(toState: .open)
    }
    
    /// Hide the setting menu.
    func hideSettings(){
        settingsViewController.view.frame = CGRect(x: 0 - previewView.frame.size.width,
                                                   y: previewView.frame.size.height - 250,
                                                   width: previewView.frame.size.width,
                                                   height: 160)
        animateSettingsButton(toState: .close)
    }
    
    /**
     Animate the settings button.
     
     - parameter state: The state for opening or closing animation.
     - **.open** will animate the settingsView to opened state.
     - **.close** will animate the settingsView to closed state.
     */
    func animateSettingsButton(toState state: SettingMenuState) {
        switch state {
        case .open:
            settingsButtonArrow.image = #imageLiteral(resourceName: "ArrowLeft")
            settingsButtonArrow.frame = CGRect(x: arrowFrame.origin.x + 20,
                                               y: arrowFrame.origin.y,
                                               width: 10,
                                               height: 30)
            
            settingsButtonGridView.frame = CGRect(x: self.gridFrame.origin.x - 10,
                                              y: gridFrame.origin.y,
                                              width: 30,
                                              height: 30)
        case .close:
            self.settingsButtonArrow.image = #imageLiteral(resourceName: "ArrowRight")
            self.settingsButtonArrow.frame = CGRect(x: self.arrowFrame.origin.x,
                                                    y: self.arrowFrame.origin.y,
                                                    width: 10,
                                                    height: 30)
            
            self.settingsButtonGridView.frame = CGRect(x: self.gridFrame.origin.x + 10,
                                                   y: self.gridFrame.origin.y,
                                                   width: 30,
                                                   height: 30)
        }
    }
}
