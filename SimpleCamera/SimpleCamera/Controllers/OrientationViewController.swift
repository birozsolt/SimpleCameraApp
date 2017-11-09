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
    private var motionManager: CMMotionManager!
    private let motionQueue = OperationQueue()
    private var horizontalLine = UIView()
    private var verticalLine = UIView()
    
    convenience init(something: Bool) {
        self.init()
        motionManager = CMMotionManager()
    }
    
    func startMotionUpdate() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0
            motionManager.startDeviceMotionUpdates(to: motionQueue) { (motionData, error) in
                print(motionData ?? "No motion Data")
            }
        } else {
            print("No motion-service available")
        }
    }
    
    func stopMotionUpdate(){
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }
}
