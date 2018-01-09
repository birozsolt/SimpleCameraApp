//
//  SettingsView.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 31/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

/// SettingsView protocol used for implementing button actions.
protocol SettingsViewProtocol {
    /**
     Video player cell touch handler function.
     - throws: *CameraControllerError* if no video found to play.
     */
    func videoPlayerTapped() throws
    
    /**
     Exposure cell touch handler function.
     - throws: *CameraControllerError* if no camera device available.
     */
    func exposureTapped() throws
    
    /**
     Flash cell touch handler function.
     - throws: *CameraControllerError* if no camera device available.
     */
    func flashTapped() throws
    
    /**
     TimeLapse builder cell touch handler function.
     - throws: *CameraControllerError* if *imageArray* is empty.
     */
    func buildTimeLapse() throws
}

/// UIView class for setting the settings view
class SettingsView: UIView {
    var delegate : SettingsViewProtocol?
    
    private var videoPlayerCell = SettingsCell(frame: CGRect.zero)
    private var exposureCell = SettingsCell(frame: CGRect.zero)
    private var flashCell = SettingsCell(frame: CGRect.zero)
    private var timeLapseBuildCell = SettingsCell(frame: CGRect.zero)
    
    private var currentIndex = 1
    
    //MARK: - Object Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(videoPlayerCell)
        addSubview(exposureCell)
        addSubview(flashCell)
        addSubview(timeLapseBuildCell)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup funcions for views
    
    /// It setting up settings screen views.
    private func setupViews() {
        setupBackground()
        
        videoPlayerCell.autoPinEdge(toSuperviewEdge: .left)
        videoPlayerCell.autoPinEdge(toSuperviewEdge: .top)
        videoPlayerCell.autoSetDimensions(to: CGSize(width: 70, height: 70))
        setupViews(for: videoPlayerCell, withType: SettingsType.VideoPlayer)
        videoPlayerCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(startVideoPlayer)))
        
        exposureCell.autoPinEdge(.left, to: .right, of: videoPlayerCell, withOffset: 10)
        exposureCell.autoPinEdge(toSuperviewEdge: .top)
        exposureCell.autoSetDimensions(to: CGSize(width: 70, height: 70))
        setupViews(for: exposureCell, withType: SettingsType.Exposure)
        exposureCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(adjustExposure)))
        
        flashCell.autoPinEdge(.left, to: .right, of: exposureCell, withOffset: 10)
        flashCell.autoPinEdge(toSuperviewEdge: .top)
        flashCell.autoSetDimensions(to: CGSize(width: 70, height: 70))
        setupViews(for: flashCell, withType: SettingsType.Flash)
        flashCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleFlash)))
        
        timeLapseBuildCell.autoPinEdge(.left, to: .right, of: flashCell, withOffset: 10)
        timeLapseBuildCell.autoPinEdge(toSuperviewEdge: .top)
        timeLapseBuildCell.autoSetDimensions(to: CGSize(width: 70, height: 70))
        setupViews(for: timeLapseBuildCell, withType: SettingsType.TimeLapse)
        timeLapseBuildCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buildTimeLapse)))
    }
    
    /// It setting up the background of the *SettingView*.
    private func setupBackground() {
        backgroundColor = UIColor.black
        alpha = 0.8
        isHidden = true
        layer.cornerRadius = 20
    }
    
    /**
     It setting up the *cell* with the given *type*.
     - parameter cell: The *SettingsCell*, which will be configured.
     - parameter type: The *SettingsType*, how the *cell* will be configured.
     */
    private func setupViews(for cell: SettingsCell, withType type: SettingsType){
        
        cell.cellImage.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        cell.cellImage.autoPinEdge(toSuperviewEdge: .right)
        cell.cellImage.autoPinEdge(toSuperviewEdge: .left)
        cell.cellImage.autoSetDimension(.height, toSize: 40)
        cell.cellImage.contentMode = .scaleAspectFit
        
        cell.cellLabel.autoPinEdge(.top, to: .bottom, of: cell.cellImage, withOffset: 5)
        cell.cellLabel.autoPinEdge(toSuperviewEdge: .right)
        cell.cellLabel.autoPinEdge(toSuperviewEdge: .left)
        cell.cellLabel.autoSetDimension(.height, toSize: 15)
        cell.cellLabel.font = getFont(.light, withSize: 15)
        cell.cellLabel.textColor = UIColor.white
        cell.cellLabel.textAlignment = .center
        
        switch type {
        case .VideoPlayer:
            cell.cellImage.image = #imageLiteral(resourceName: "VideoPlayer")
            cell.cellLabel.text = SettingsType.VideoPlayer.rawValue
        case .Exposure:
            cell.cellImage.image = #imageLiteral(resourceName: "Exposure0")
            cell.cellLabel.text = SettingsType.Exposure.rawValue
        case .Flash:
            cell.cellImage.image = #imageLiteral(resourceName: "FlashOff")
            cell.cellLabel.text = SettingsType.Flash.rawValue
        case .TimeLapse:
            cell.cellImage.image = #imageLiteral(resourceName: "TimeLapse")
            cell.cellLabel.text = SettingsType.TimeLapse.rawValue
        }
    }
    
    //MARK: - Button image changer functions
    
    /**
     It change the videoPlayer cell image.
     - parameter image: Change videoPlayer cell image to *image*.
     */
    private func changevideoPlayerCellImage(to image: UIImage){
        videoPlayerCell.cellImage.image = image
    }
    
    /**
     It change the exposure cell image.
     */
    func changeExposureCellImage(){
        var exposureList = [#imageLiteral(resourceName: "Exposure0"), #imageLiteral(resourceName: "Exposure+1"), #imageLiteral(resourceName: "Exposure+2"), #imageLiteral(resourceName: "Exposure-2"), #imageLiteral(resourceName: "Exposure-1")]
        if currentIndex < 5 {
            let currentImage = exposureList[currentIndex]
            exposureCell.cellImage.image = currentImage
            currentIndex += 1
        } else {
            currentIndex = 0
        }
    }
    
    /**
     It change the flash cell image.
     - parameter image: Change flash cell image to *image*.
     */
    func changeFlashCellImage(to image: UIImage){
        flashCell.cellImage.image = image
    }
    
    // MARK: - Cell touch handler functions
    
    /**
     It is called after touching the videoPlayer button.
     - Implemented in the class which adopted *SettingsViewProtocol*.
     */
    func startVideoPlayer(){
        do {
            try delegate?.videoPlayerTapped()
        }
        catch {
            ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.videoPlayerError)
        }
    }
    
    /**
     It is called after touching the exposure button.
     - Implemented in the class which adopted *SettingsViewProtocol*.
     */
    func adjustExposure(){
        do {
            try delegate?.exposureTapped()
        }
        catch {
            ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.noCamerasAvailable)
        }
    }
    
    /**
     It is called after touching the flash button.
     - Implemented in the class which adopted *SettingsViewProtocol*.
     */
    func toggleFlash() {
        do {
            try delegate?.flashTapped()
        }
        catch {
            ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.noCamerasAvailable)
        }
    }
    
    /**
     It is called after touching the buildTimeLapse button.
     - Implemented in the class which adopted *SettingsViewProtocol*.
     */
    func buildTimeLapse(){
        do {
            try delegate?.buildTimeLapse()
        }
        catch {
            ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.timeLapseBuildError)
        }
    }
}
