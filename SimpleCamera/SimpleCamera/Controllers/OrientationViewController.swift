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
    let orientationView = OrientationView(frame: CGRect.zero)
    
    override func loadView() {
        self.view = orientationView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        motionManager = CMMotionManager()
    }
    
    func startMotionUpdate() {
        if (motionManager.isDeviceMotionAvailable && !motionManager.isDeviceMotionActive) {
            motionManager.deviceMotionUpdateInterval = 1.0
            motionManager.startDeviceMotionUpdates(to: motionQueue) { (motionData, error) in
                if error == nil {
                    guard let data = motionData else {
                        print("No motion Data")
                        return
                    }
                    self.handleMotionUpdate(deviceMotion: data)
                } else {
                    print(error ?? "Some Error")
                }
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
    
    func handleMotionUpdate(deviceMotion: CMDeviceMotion){
        let attitude = deviceMotion.attitude
        let roll = degrees(radians: attitude.roll)
        let pitch = degrees(radians: attitude.pitch)
        let yaw = degrees(radians: attitude.yaw)
        print("Roll: \(roll), Pitch: \(pitch), Yaw: \(yaw)")
    }
    
    private func degrees(radians:Double) -> Double {
        return 180 / .pi * radians
    }
}
