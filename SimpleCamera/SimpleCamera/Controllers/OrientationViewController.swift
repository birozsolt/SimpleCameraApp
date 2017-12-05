//
//  OrientationViewController.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 09/11/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import CoreMotion
import UIKit

class OrientationViewController: UIViewController {
    
    private var motionManager = CMMotionManager()
    private let motionQueue = OperationQueue()
    
    private var referenceQuaternion = CMQuaternion()
    private var referenceRoll = 0.0
    private var referencePitch = 0.0
    private var referenceYaw = 0.0
    
    let orientationView = OrientationView(frame: CGRect.zero)
    
    override func loadView() {
        self.view = orientationView
    }
    
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
    
    func stopMotionUpdate(){
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
//    func helperFunc(deviceMotion: CMDeviceMotion){
//        let e = CMQuaternion(x: 0, y: 0, z: 1, w: 0)
//        let cm = deviceMotion.attitude.quaternion
//        var quat = CMQuaternion(x: cm.x, y: cm.y, z: cm.z, w: cm.w)
//        let quatConjugate = CMQuaternion(x: -cm.x, y: -cm.y, z: -cm.z, w: -cm.w)
//        quat.multiplyByRight(quaternion: e)
//        quat.multiplyByRight(quaternion: quatConjugate)
//        print(quat.x, quat.y, quat.z)
//    }
    
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

extension CMQuaternion {
    mutating func multiplyByRight(quaternion q: CMQuaternion) -> CMQuaternion {
        let newW = w * q.w - x * q.x - y * q.y - z * q.z
        let newX = w * q.x + x * q.w + y * q.z - z * q.y
        let newY = w * q.y + y * q.w + z * q.x - x * q.z
        let newZ = w * q.z + z * q.w + x * q.y - y * q.x
        w = newW
        x = newX
        y = newY
        z = newZ
        return self
    }
}
