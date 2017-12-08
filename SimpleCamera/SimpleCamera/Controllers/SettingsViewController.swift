//
//  SettingsViewController.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 31/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit
import AVFoundation

enum SettingsType : String {
    case VideoPlayer
    case Exposure
    case Flash
    case TimeLapse
    
    static var count: Int { return SettingsType.TimeLapse.hashValue + 1}
}

class SettingsViewController: UIViewController {
    
    var flashMode = AVCaptureFlashMode.off
    
    var settingsView = SettingsView(frame: CGRect.zero)
    
    var videoViewController: VideoPlayerViewController?
    var timeLapseBuilder: TimeLapseBuilder?
    var videoUrl : URL?
    var currentExposureIndex = 1
    
    override func loadView() {
        self.view = settingsView
        settingsView.delegate = self
    }
}

extension SettingsViewController : SettingsViewProtocol {
    
    func videoPlayerTapped() throws {
        guard let videoUrl = videoUrl else {
            throw CameraControllerError.invalidOperation
        }
        videoViewController = VideoPlayerViewController(videoUrl: videoUrl)
        gNavigationViewController?.pushViewController(videoViewController!, animated: true)
    }
    
    func exposureTapped() throws {
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
            throw CameraControllerError.noCamerasAvailable
        }
        
        let minISO = device.activeFormat.minISO
        let maxISO = device.activeFormat.maxISO
        let isoRange = maxISO - minISO
        let isoCounter = isoRange / 5
        let midIso = minISO + isoCounter * 2
        var isoList = [midIso, midIso + isoCounter, midIso + isoCounter * 2, midIso - isoCounter * 2, midIso - isoCounter]
        settingsView.changeExposureCellImage()
        if currentExposureIndex < 5 {
            let currentIso = isoList[currentExposureIndex]
            do {
                try device.lockForConfiguration()
                device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, iso: currentIso, completionHandler: nil)
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
            currentExposureIndex += 1
        } else {
            currentExposureIndex = 0
        }
        
    }
    
    func flashTapped() throws {
        
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
            throw CameraControllerError.noCamerasAvailable
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
    
    func buildTimeLapse() throws {
        if imageArray.count > 0 {
            self.timeLapseBuilder = TimeLapseBuilder(photoArray: imageArray)
            LoadingBox.sharedInstance.block()
            self.timeLapseBuilder!.build(
                { (progress: Progress) in
                    NSLog("Progress: \(progress.completedUnitCount) / \(progress.totalUnitCount)")
            },
                success: { url in
                    NSLog("Output written to \(url)")
                    self.videoUrl = url
            },
                failure: { error in
                    NSLog("failure: \(error)")
            }
            )
            LoadingBox.sharedInstance.unblock()
        } else {
            throw CameraControllerError.invalidOperation
        }
    }
}
