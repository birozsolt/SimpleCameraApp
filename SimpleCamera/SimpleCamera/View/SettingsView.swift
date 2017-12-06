//
//  SettingsView.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 31/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

protocol SettingsViewProtocol {
    func videoPlayerTapped() throws
    func exposureTapped() throws
    func flashTapped() throws
    func buildTimeLapse()
}

class SettingsView: UIView {
    public var delegate : SettingsViewProtocol?
    
    private var videoPlayerCell = SettingsCell(frame: CGRect.zero)
    private var exposureCell = SettingsCell(frame: CGRect.zero)
    private var flashCell = SettingsCell(frame: CGRect.zero)
    private var timeLapseBuildCell = SettingsCell(frame: CGRect.zero)
    
    private var currentIndex = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(videoPlayerCell)
        self.addSubview(exposureCell)
        self.addSubview(flashCell)
        self.addSubview(timeLapseBuildCell)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        setupBackground()
        
        videoPlayerCell.autoPinEdge(toSuperviewEdge: .left)
        videoPlayerCell.autoPinEdge(toSuperviewEdge: .top)
        videoPlayerCell.autoSetDimensions(to: CGSize(width: 70, height: 70))
        videoPlayerCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(startVideoPlayer)))
        setupViews(for: videoPlayerCell, withType: SettingsType.VideoPlayer)
        
        exposureCell.autoPinEdge(.left, to: .right, of: videoPlayerCell, withOffset: 10)
        exposureCell.autoPinEdge(toSuperviewEdge: .top)
        exposureCell.autoSetDimensions(to: CGSize(width: 70, height: 70))
        exposureCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(adjustExposure)))
        setupViews(for: exposureCell, withType: SettingsType.Exposure)
        
        flashCell.autoPinEdge(.left, to: .right, of: exposureCell, withOffset: 10)
        flashCell.autoPinEdge(toSuperviewEdge: .top)
        flashCell.autoSetDimensions(to: CGSize(width: 70, height: 70))
        flashCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleFlash)))
        setupViews(for: flashCell, withType: SettingsType.Flash)
        
        timeLapseBuildCell.autoPinEdge(.left, to: .right, of: flashCell, withOffset: 10)
        timeLapseBuildCell.autoPinEdge(toSuperviewEdge: .top)
        timeLapseBuildCell.autoSetDimensions(to: CGSize(width: 70, height: 70))
        timeLapseBuildCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buildTimeLapse)))
        setupViews(for: timeLapseBuildCell, withType: SettingsType.TimeLapse)

    }
    
    func setupBackground() {
        self.backgroundColor = UIColor.black
        self.alpha = 0.8
        self.isHidden = true
        self.layer.cornerRadius = 20
    }
    
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
        cell.cellLabel.font = UIFont(name: getFont(font: .light), size: 15)
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
    
    func changevideoPlayerCellImage(to image: UIImage){
        videoPlayerCell.cellImage.image = image
    }
    
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
    
    func changeFlashCellImage(to image: UIImage){
        flashCell.cellImage.image = image
    }
    
    func startVideoPlayer(){
        do {
            try delegate?.videoPlayerTapped()
        }
        catch {
            let alert = UIAlertController(title: "titleError".localized, message: "videoPlayerMessage".localized, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "okButton".localized, style: UIAlertActionStyle.default, handler: nil))
            gNavigationViewController?.topViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func adjustExposure(){
        do {
         try delegate?.exposureTapped()
        }
        catch {
            let alert = UIAlertController(title: "titleError".localized, message: "noCamerasAvailable".localized, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "okButton".localized, style: UIAlertActionStyle.default, handler: nil))
            gNavigationViewController?.topViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func toggleFlash() {
        do {
            try delegate?.flashTapped()
        }
        catch {
            let alert = UIAlertController(title: "titleError".localized, message: "noCamerasAvailable".localized, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "okButton".localized, style: UIAlertActionStyle.default, handler: nil))
            gNavigationViewController?.topViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func buildTimeLapse(){
        delegate?.buildTimeLapse()
    }
}
