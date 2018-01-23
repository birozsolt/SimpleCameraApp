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
     Orientation Assistant cell touch handler function.
     */
    func orientationAssistTapped()
    
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
    
    /**
     OnionSkin cell touch handler function.
     */
    func addOnionSkinning()
}

/// UIView class for setting the settings view
class SettingsView: UIView {
    var delegate : SettingsViewProtocol?
    
    private var videoPlayerCell = SettingsCell(frame: CGRect.zero)
    private var orientationCell = SettingsCell(frame: CGRect.zero)
    private var flashCell = SettingsCell(frame: CGRect.zero)
    private var timeLapseBuildCell = SettingsCell(frame: CGRect.zero)
    private var onionSkinningCell = SettingsCell(frame: CGRect.zero)
    
    //MARK: - Object Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(videoPlayerCell)
        addSubview(orientationCell)
        addSubview(flashCell)
        addSubview(timeLapseBuildCell)
        addSubview(onionSkinningCell)
        
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
        setupViews(for: videoPlayerCell, withType: SettingsType.VideoPlayer, action: #selector(startVideoPlayer))
        
        orientationCell.autoPinEdge(.left, to: .right, of: videoPlayerCell, withOffset: 10)
        orientationCell.autoPinEdge(toSuperviewEdge: .top)
        setupViews(for: orientationCell, withType: SettingsType.Orientation, action: #selector(orientationalAssistant))
        
        flashCell.autoPinEdge(.left, to: .right, of: orientationCell, withOffset: 10)
        flashCell.autoPinEdge(toSuperviewEdge: .top)
        setupViews(for: flashCell, withType: SettingsType.Flash, action: #selector(toggleFlash))
        
        timeLapseBuildCell.autoPinEdge(.left, to: .right, of: flashCell, withOffset: 10)
        timeLapseBuildCell.autoPinEdge(toSuperviewEdge: .top)
        setupViews(for: timeLapseBuildCell, withType: SettingsType.TimeLapse, action: #selector(buildTimeLapse))
        
        onionSkinningCell.autoPinEdge(toSuperviewEdge: .left)
        onionSkinningCell.autoPinEdge(.top, to: .bottom, of: videoPlayerCell, withOffset: 10)
        setupViews(for: onionSkinningCell, withType: SettingsType.OnionSkin, action: #selector(addOnionSkinning))

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
    private func setupViews(for cell: SettingsCell, withType type: SettingsType, action selector: Selector){
        cell.autoSetDimensions(to: CGSize(width: 70, height: 70))
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))
        
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
        case .Orientation:
            cell.cellImage.image = #imageLiteral(resourceName: "OrientationOff")
            cell.cellLabel.text = SettingsType.Orientation.rawValue
        case .Flash:
            cell.cellImage.image = #imageLiteral(resourceName: "FlashOff")
            cell.cellLabel.text = SettingsType.Flash.rawValue
        case .TimeLapse:
            cell.cellImage.image = #imageLiteral(resourceName: "TimeLapse")
            cell.cellLabel.text = SettingsType.TimeLapse.rawValue
        case .OnionSkin:
            cell.cellImage.image = #imageLiteral(resourceName: "OnionSkinOff")
            cell.cellLabel.text = SettingsType.OnionSkin.rawValue
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
     It change the orientation cell image.
     */
    func changeOrientationCellImage(to image: UIImage){
        if image == #imageLiteral(resourceName: "OrientationOff") {
            orientationCell.backgroundColor = .clear
        } else {
            orientationCell.backgroundColor = .darkGray
        }
        orientationCell.cellImage.image = image
    }
    
    /**
     It change the onionSkin cell image.
     */
    func changeOnionSkinCellImage(to image: UIImage){
        if image == #imageLiteral(resourceName: "OnionSkinOff") {
            onionSkinningCell.backgroundColor = .clear
        } else {
            onionSkinningCell.backgroundColor = .darkGray
        }
        onionSkinningCell.cellImage.image = image
    }
    
    /**
     Returns the orientation cell image
     */
    func getOrientationCellImage() -> UIImage{
        return orientationCell.cellImage.image!
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
     It is called after touching the orientation button.
     - Implemented in the class which adopted *SettingsViewProtocol*.
     */
    func orientationalAssistant(){
        delegate?.orientationAssistTapped()
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
    
    /**
     It is called after touching the OnionSkinning button.
     - Implemented in the class which adopted *SettingsViewProtocol*.
     */
    func addOnionSkinning(){
        delegate?.addOnionSkinning()
    }
}
