//
//  SettingsViewController.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 31/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit
import AVFoundation

class SettingsViewController: UIViewController {
    
    var flashMode = AVCaptureFlashMode.off
    
    var settingsView = SettingsView(frame: CGRect.zero)
    
    override func loadView() {
        self.view = settingsView
        settingsView.delegate = self
    }
}

extension SettingsViewController : SettingsViewProtocol {
    
    func brightnessTapped() {
        
    }
    
    func exposureTapped() throws{
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
            throw CameraViewController.CameraControllerError.noCamerasAvailable
        }
        
        let minISO = device.activeFormat.minISO
        let maxISO = device.activeFormat.maxISO
        let isoRange = maxISO - minISO
        device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, iso: maxISO) { (time) in
            
        }
        print(isoRange)
    }
    
    func flashTapped() throws {
        
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
            throw CameraViewController.CameraControllerError.noCamerasAvailable
        }
        
        switch flashMode {
        case .on:
            flashMode = .off
            settingsView.changeFlashCellImage(to: #imageLiteral(resourceName: "FlashOff"))
        case .auto:
            flashMode = .on
            settingsView.changeFlashCellImage(to: #imageLiteral(resourceName: "FlashOn"))
        case .off:
            flashMode = .auto
            settingsView.changeFlashCellImage(to: #imageLiteral(resourceName: "FlashAuto"))
        }
        
        
        if device.hasFlash {
            do {
                try device.lockForConfiguration()
                device.flashMode = flashMode
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
}
