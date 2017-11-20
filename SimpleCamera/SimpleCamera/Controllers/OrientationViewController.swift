//
//  OrientationViewController.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 09/11/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import CoreMotion
import UIKit

enum SliderMoves {
    case left
    case right
    case up
    case down
}

class OrientationViewController: UIViewController {
    
    private var motionManager = CMMotionManager()
    private let motionQueue = OperationQueue()
    
    private var referenceQuaternion = CMQuaternion()
    private var referenceRoll = 0.0
    private var referencePitch = 0.0
    private var referenceYaw = 0.0
    
    var counter = 0
    let orientationView = OrientationView(frame: CGRect.zero)
    
    override func loadView() {
        self.view = orientationView
    }
    
    func startMotionUpdate() {
        if (motionManager.isDeviceMotionAvailable && !motionManager.isDeviceMotionActive) {
            motionManager.deviceMotionUpdateInterval = 0.5
            motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xTrueNorthZVertical, to: motionQueue, withHandler: { (motionData, error) in
                if error == nil {
                    guard let data = motionData else {
                        print("No motion Data")
                        return
                    }
                    self.referenceQuaternion = (self.motionManager.deviceMotion?.attitude.quaternion)!
                    self.referenceRoll = atan2(2 * (self.referenceQuaternion.y * self.referenceQuaternion.w - self.referenceQuaternion.x * self.referenceQuaternion.z),
                                          1 - 2 * (self.referenceQuaternion.y * self.referenceQuaternion.y - self.referenceQuaternion.z*self.referenceQuaternion.z)).toDegrees
                    self.referencePitch = atan2(2 * (self.referenceQuaternion.x * self.referenceQuaternion.w + self.referenceQuaternion.y * self.referenceQuaternion.z),
                                           1 - 2 * (self.referenceQuaternion.x * self.referenceQuaternion.x - self.referenceQuaternion.z * self.referenceQuaternion.z)).toDegrees
                    self.referenceYaw = asin(2 * (self.referenceQuaternion.x * self.referenceQuaternion.y + self.referenceQuaternion.w * self.referenceQuaternion.z)).toDegrees
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
    
    private func motionRefresh(deviceMotion: CMDeviceMotion) {
        let quat = deviceMotion.attitude.quaternion
        
        // roll (x-axis rotation)
        let currentRoll = atan2(2 * (quat.y * quat.w - quat.x * quat.z), 1 - 2 * (quat.y * quat.y - quat.z*quat.z)).toDegrees
        
        // pitch (y-axis rotation)
        let currentPitch = atan2(2 * (quat.x * quat.w + quat.y * quat.z), 1 - 2 * (quat.x * quat.x - quat.z * quat.z)).toDegrees
        
        // yaw (z-axis rotation)
        let currentYaw = asin(2 * (quat.x * quat.y + quat.w * quat.z)).toDegrees
        
        //let roll = 0
        counter += 1
        if (referenceYaw - currentYaw < 10 && counter == 100) {
            moveHorizontalSlider(to: .left)
            counter = 0
        }
        
        if referencePitch - currentPitch == 10 {
            moveVerticalSlider(to: .down)
        }
        
        print("Roll: \(currentRoll), Pitch: \(currentPitch), Yaw: \(currentYaw)")
    }
    
}

extension OrientationViewController : OrientationViewProtocol {
    //MARK: - Orientation View animations
    
    func moveHorizontalSlider(to direction: SliderMoves){
        let sliderFrame = orientationView.convert(orientationView.horizontalSlider.frame, from: orientationView.horizontalLine)
        
        switch direction {
        case .right:
            UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.orientationView.horizontalSlider.frame = CGRect(x: sliderFrame.origin.x + 5, y: sliderFrame.origin.y, width: 5, height: 5)
            })
        case .left:
            UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.orientationView.horizontalSlider.frame = CGRect(x: sliderFrame.origin.x - 5, y: sliderFrame.origin.y, width: 5, height: 5)
            })
        default: break
        }
    }
    
    func moveVerticalSlider(to direction: SliderMoves){
        let sliderFrame = orientationView.convert(orientationView.verticalSlider.frame, from: orientationView.verticalLine)
        
        switch direction {
        case .down:
            UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.orientationView.verticalSlider.frame = CGRect(x: sliderFrame.origin.x, y: sliderFrame.origin.y + 5, width: 5, height: 5)
            })
        case .up:
            UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.orientationView.verticalSlider.frame = CGRect(x: sliderFrame.origin.x, y: sliderFrame.origin.y - 5, width: 5, height: 5)
            })
        default: break
        }
    }
}
