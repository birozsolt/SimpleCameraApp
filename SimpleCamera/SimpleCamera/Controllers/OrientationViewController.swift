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
    
    ///The reference quaternion representing the device's attitude.
    private var referenceQuaternion = CMQuaternion()
    
    /**
     The reference roll of the device, in degrees.
     
     A roll is a rotation around a longitudinal axis that passes through the device from its top to bottom.
     */
    private var referenceRoll = 0.0
    
    /**
     The reference pitch of the device, in degrees.
     
     A pitch is a rotation around a lateral axis that passes through the device from side to side.
     */
    private var referencePitch = 0.0
    
    /**
     The reference yaw of the device, in degrees.
     
     A yaw is a rotation around an axis that runs vertically through the device.
     It is perpendicular to the body of the device, with its origin at the center of gravity and directed toward the bottom of the device.
     */
    private var referenceYaw = 0.0
    
    ///The view that the *OrientationViewController* manages.
    let orientationView = OrientationView(frame: CGRect.zero)
    
    
    override func loadView() {
        self.view = orientationView
    }
    
    //MARK: - Motion controll functions

    /**
     If the device-motion service is available on the device, 
     then starts device-motion updates on *motionQueue* operation queue twice in every secound.
     
     Calculates the reference orientation, which is the device current orientation.
    */
    func startMotionUpdate() {
        if (motionManager.isDeviceMotionAvailable && !motionManager.isDeviceMotionActive) {
            motionManager.deviceMotionUpdateInterval = 0.5
            motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xTrueNorthZVertical, to: motionQueue, withHandler:
                { [unowned self] (motionData, error) in
                if error == nil {
                    guard let data = motionData else {
                        print("No motion Data")
                        return
                    }
                    if self.referenceYaw == 0 && self.referenceRoll == 0 && self.referencePitch == 0 {
                        self.referenceQuaternion = (self.motionManager.deviceMotion?.attitude.quaternion)!
                        self.referenceRoll = atan2(2 * (self.referenceQuaternion.y * self.referenceQuaternion.w - self.referenceQuaternion.x * self.referenceQuaternion.z),
                                                   1 - 2 * (self.referenceQuaternion.y * self.referenceQuaternion.y - self.referenceQuaternion.z*self.referenceQuaternion.z)).toDegrees
                        self.referencePitch = atan2(2 * (self.referenceQuaternion.x * self.referenceQuaternion.w + self.referenceQuaternion.y * self.referenceQuaternion.z),
                                                    1 - 2 * (self.referenceQuaternion.x * self.referenceQuaternion.x - self.referenceQuaternion.z * self.referenceQuaternion.z)).toDegrees
                        self.referenceYaw = asin(2 * (self.referenceQuaternion.x * self.referenceQuaternion.y + self.referenceQuaternion.w * self.referenceQuaternion.z)).toDegrees
                    }
                    self.motionRefresh(deviceMotion: data)
                } else {
                    print(error ?? "Some Error")
                }
            })
        } else {
            print("No motion-service available")
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
        deviceMotion.attitude.multiply(byInverseOf: deviceMotion.attitude)
        // roll (x-axis rotation)
        let currentRoll = atan2(2 * (quat.y * quat.w - quat.x * quat.z), 1 - 2 * (quat.y * quat.y - quat.z*quat.z)).toDegrees
        
        // pitch (y-axis rotation)
        let currentPitch = atan2(2 * (quat.x * quat.w + quat.y * quat.z), 1 - 2 * (quat.x * quat.x - quat.z * quat.z)).toDegrees
        
        // yaw (z-axis rotation)
        let currentYaw = asin(2 * (quat.x * quat.y + quat.w * quat.z)).toDegrees
        
        if currentPitch.distance(to: referencePitch) > 10 {
            orientationView.setVerticalSlider(to: SliderValue.increase)
            referencePitch = currentPitch
        } else if currentPitch.distance(to: referencePitch) < -10 {
            orientationView.setVerticalSlider(to: SliderValue.decrease)
            referencePitch = currentPitch
        }
        
        if currentYaw.distance(to: referenceYaw) > 10 {
            orientationView.setHorizontalSlider(to: SliderValue.increase)
            referenceYaw = currentYaw
        } else if currentRoll.distance(to: referenceRoll) < -10 {
            orientationView.setHorizontalSlider(to: SliderValue.decrease)
            referenceYaw = currentYaw
        }
        print("Roll: \(currentRoll), Pitch: \(currentPitch), Yaw: \(currentYaw)")
    }
}
