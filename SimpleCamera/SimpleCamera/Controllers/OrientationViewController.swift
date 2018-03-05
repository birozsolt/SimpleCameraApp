//
//  OrientationViewController.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 09/11/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import CoreMotion
import UIKit

/// Storing motion informations
struct MotionData {
    /// Rotation around x - axis
    var roll: CGFloat = 0
    
    /// Rotation around y - axis
    var pitch: CGFloat = 0
    
    ///Rotation around z - axis
    var yaw: CGFloat = 0
    
    // Total and average roll, pitch, yaw values of captured images
    var totalRoll : CGFloat = 0
    var averageRoll : CGFloat = 0
    var totalPitch : CGFloat = 0
    var averagePitch : CGFloat = 0
    var totalYaw : CGFloat = 0
    var averageYaw : CGFloat = 0
    
    init() {
        self.roll = 0
        self.pitch = 0
        self.yaw = 0
    }
    
    init(roll: CGFloat, pitch: CGFloat, yaw: CGFloat) {
        self.roll = roll
        self.pitch = pitch
        self.yaw = yaw
    }
}

///UIViewController class where *CoreMotion* framework used for calculating the device orientation in space.
class OrientationViewController: UIViewController {
    
    ///A *CMMotionManager* object which is the gateway to the motion services provided by iOS.
    private var motionManager = CMMotionManager()
    
    ///An operation queue used for device-motion service.
    private let motionQueue = OperationQueue()

    ///The view that the *OrientationViewController* manages.
    let orientationView = OrientationView(frame: CGRect.zero)

    /// The motion data which will be used for saving motion information on image capture
    private var motionData = MotionData(roll: 0, pitch: 0, yaw: 0)
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
            motionManager.deviceMotionUpdateInterval = 0.1
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
        
        let currentYaw = CGFloat(asin(2 * quat.x * quat.y + 2 * quat.z * quat.w)).toDegrees
        
        motionData.pitch = currentPitch
        motionData.roll = currentRoll
        motionData.yaw = currentYaw
    }
    
    func getMotionData() -> MotionData {
        return motionData
    }
}
