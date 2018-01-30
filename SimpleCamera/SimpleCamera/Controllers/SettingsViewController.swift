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
    case Orientation
    case Flash
    case TimeLapse
    case OnionSkin
    
    ///Returns the size of the enum.
    static var count: Int { return SettingsType.OnionSkin.hashValue + 1}
}

///UIViewController class for managing the settings screen.
class SettingsViewController: UIViewController {
    
    ///The capture device flash mode.
    fileprivate var flashMode = AVCaptureFlashMode.off
    
    ///The view that the *SettingsViewController* manages.
    var settingsView = SettingsView(frame: CGRect.zero)
    
    ///The *VideoPlayerViewController* instance for playing videos.
    fileprivate var videoViewController: VideoPlayerViewController?
    
    ///The settings of the video.
    fileprivate let settings = RenderSettings()
    
    //MARK: - View Lifecycle
    
    override func loadView() {
        view = settingsView
        settingsView.delegate = self
    }
}

//MARK: SettingsViewProtocol extension

extension SettingsViewController : SettingsViewProtocol {
    
    func videoPlayerTapped() throws {
        guard let videoUrl = settings.outputURL, !Platform.isSimulator else {
            throw CameraControllerError.invalidOperation
        }
        videoViewController = VideoPlayerViewController(videoUrl: videoUrl)
        gNavigationViewController?.pushViewController(videoViewController!, animated: true)
    }
    
    func orientationAssistTapped() {
//        if settingsView.getOrientationCellImage() == #imageLiteral(resourceName: "OrientationOff") {
//            CameraView.orientationViewController.startMotionUpdate()
//            CameraView.orientationViewController.view.isHidden = false
//            settingsView.changeOrientationCellImage(to: #imageLiteral(resourceName: "OrientationOn"))
//        } else {
//            CameraView.orientationViewController.stopMotionUpdate()
//            CameraView.orientationViewController.view.isHidden = true
//            settingsView.changeOrientationCellImage(to: #imageLiteral(resourceName: "OrientationOff"))
//        }
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
    
    func addOnionSkinning() {
//        if CameraView.onionEffectLayer.isHidden {
//            settingsView.changeOnionSkinCellImage(to: #imageLiteral(resourceName: "OnionSkinOn"))
//            CameraView.onionEffectLayer.isHidden = false
//            if CameraView.onionEffectLayer.image == nil {
//                ErrorMessage.sharedInstance.show(LocalizedKeys.titleWarning, message: LocalizedKeys.onionEffectLayerError)
//            }
//        } else {
//            settingsView.changeOnionSkinCellImage(to: #imageLiteral(resourceName: "OnionSkinOff"))
//            CameraView.onionEffectLayer.isHidden = true
//        }
    }
}
