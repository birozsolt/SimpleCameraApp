//
//  OrientationViewController.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 09/11/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import CoreMotion
import UIKit

///UIViewController class where *CoreMotion* framework used for calculating the device orientation in space.
class OrientationViewController: UIViewController {
    
    ///A *CMMotionManager* object which is the gateway to the motion services provided by iOS.
    private var motionManager = CMMotionManager()
    
    ///An operation queue used for device-motion service.
    private let motionQueue = OperationQueue()

    ///The view that the *OrientationViewController* manages.
    let orientationView = OrientationView(frame: CGRect.zero)

    //MARK: - View Lifecycle
    
    override func loadView() {
        view = orientationView
    }
    
    //MARK: - Motion controll functions
    
    /**
     If the device-motion service is available on the device,
     then starts device-motion updates on *motionQueue* operation queue twice in every secound.
     
     Calculates the reference orientation, which is the device current orientation.
     */
    func startMotionUpdate() {
        if (motionManager.isDeviceMotionAvailable && !motionManager.isDeviceMotionActive) {
            motionManager.deviceMotionUpdateInterval = 1.0
            let myFrame = CMAttitudeReferenceFrame.xArbitraryZVertical
            guard CMMotionManager.availableAttitudeReferenceFrames().contains(myFrame) else {
                ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.referenceFrameError)
                return
            }
            motionManager.startDeviceMotionUpdates(using: myFrame, to: motionQueue, withHandler:
                { [unowned self] (motionData, error) in
                    if error == nil {
                        guard let data = motionData else {
                            print("No motion Data")
                            return
                        }
                        self.motionRefresh(deviceMotion: data)
                    } else {
                        print(error ?? "Some Error")
                    }
            })
        } else {
            ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.motionServiceError)
        }
    }
    
    /// If the application is receiving updates from the device-motion service, then it stops device-motion updates.
    func stopMotionUpdate(){
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    /**
     Calculate the device orientation from the given parameter, and set the *orientationView* sliders.
     - parameter deviceMotion: An instance of *CMDeviceMotion* encapsulates measurements of the attitude, rotation rate, and acceleration of a device.
     */
    private func motionRefresh(deviceMotion: CMDeviceMotion) {
        let quat = deviceMotion.attitude.quaternion
        
        // pitch (y-axis rotation)
        let currentPitch = CGFloat(atan2(2 * (quat.x * quat.w + quat.y * quat.z), 1 - 2 * (quat.x * quat.x - quat.z * quat.z))).toDegrees
        OperationQueue.main.addOperation {
            self.orientationView.updateVerticalMarker(for: currentPitch)
        }
        
        // roll (x-axis rotation)
        let currentRoll = CGFloat(atan2(2 * (quat.y * quat.w - quat.x * quat.z), 1 - 2 * (quat.y * quat.y - quat.z*quat.z))).toDegrees
        OperationQueue.main.addOperation {
            self.orientationView.updateHorizontalMarker(to: currentRoll)
        }
    }
}
