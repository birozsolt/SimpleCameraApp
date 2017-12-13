//
//  SettingsViewController.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 31/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit
import AVFoundation

/**
 Settings cell types.
 
 - VideoPlayer: For playing videos.
 - Exposure: For using the capture device exposure settings.
 - Flash: For using the capture device flash.
 - TimeLapse: For building time lapse videos.
 
 - count: Returns the size of the enum.
 */
enum SettingsType : String {
    case VideoPlayer
    case Exposure
    case Flash
    case TimeLapse
    
    ///Returns the size of the enum.
    static var count: Int { return SettingsType.TimeLapse.hashValue + 1}
}

///UIViewController class for managing the settings screen.
class SettingsViewController: UIViewController {
    
    ///The capture device flash mode.
    var flashMode = AVCaptureFlashMode.off
    
    ///The view that the *SettingsViewController* manages.
    var settingsView = SettingsView(frame: CGRect.zero)
    
    ///The *VideoPlayerViewController* instance for playing videos.
    var videoViewController: VideoPlayerViewController?
    
    ///The *TimeLapseBuilder* instance for building time lapse videos.
    var timeLapseBuilder: TimeLapseBuilder?
    
    ///The path of the video.
    var videoUrl : URL?
    
    ///Exposure cell index, used for changing *ExposureCell* image.
    var currentExposureIndex = 1
    
    override func loadView() {
        self.view = settingsView
        settingsView.delegate = self
    }
}

//MARK: SettingsViewProtocol extension

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
        if imageArray.isEmpty {
            throw CameraControllerError.invalidOperation
        }
        
        let progressHUD = ProgressHUD()
        progressHUD.setTextLabel("Building your timelapse...")
        progressHUD.setProgress(0, animated: true)
        DispatchQueue.main.async {
            progressHUD.show()
        }
       
        
        self.timeLapseBuilder = TimeLapseBuilder(photoArray: imageArray)
        self.timeLapseBuilder!.build(
            { (progress: Progress) in
                NSLog("Progress: \(progress.completedUnitCount) / \(progress.totalUnitCount)")
                DispatchQueue.main.async{
                    let progressPercentage = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                    progressHUD.setProgress(progressPercentage, animated: true)
                }
        },
            success: { url in
                NSLog("Output written to \(url)")
                self.videoUrl = url
                DispatchQueue.main.async {
                    progressHUD.dismiss()
                }
        },
            failure: { error in
                NSLog("failure: \(error)")
                DispatchQueue.main.async {
                    progressHUD.dismiss()
                }
        }
        )
    }
}
