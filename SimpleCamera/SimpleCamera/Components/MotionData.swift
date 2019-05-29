//
//  MotionData.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 08/03/2018.
//  Copyright © 2018 Biro, Zsolt. All rights reserved.
//

import UIKit

/// Storing motion informations
class MotionData: NSObject {
    
    static let shared = MotionData()
    
    /// Rotation around x - axis
    var roll: CGFloat = 0
    
    /// Rotation around y - axis
    var pitch: CGFloat = 0
    
    ///Rotation around z - axis
    var yaw: CGFloat = 0
    
    // Total and average roll, pitch, yaw values of captured images
	var averageRoll: CGFloat = 0
	var averageYaw: CGFloat = 0
	var averagePitch: CGFloat = 0
	
    var totalRoll: CGFloat {
		didSet {
			self.totalRoll = oldValue + totalRoll
		}
    }
	
    var totalPitch: CGFloat {
		didSet {
			self.totalPitch = oldValue + totalPitch
		}
    }

    var totalYaw: CGFloat {
		didSet {
			self.totalYaw = oldValue + totalYaw
		}
    }
    
    fileprivate override init() {
		totalRoll = 0
		totalPitch = 0
		totalYaw = 0
        super.init()
    }
    
    fileprivate init(roll: CGFloat, pitch: CGFloat, yaw: CGFloat) {
		totalRoll = 0
		totalPitch = 0
		totalYaw = 0
        self.roll = roll
        self.pitch = pitch
        self.yaw = yaw
    }
    
    func getCurrentState() -> MotionData {
        return MotionData(roll: self.roll, pitch: self.pitch, yaw: self.yaw)
    }
    
    /**
     Adding image to the array and calculating average motion data.
     - parameter newElement: The new image which we want to add to the Array
     */
    func imageInfo(_ image: UIImage) {
        if let data = image.motionData {
            totalRoll = data.roll
            totalPitch = data.pitch
            totalYaw = data.yaw
            averageRoll = totalRoll / CGFloat(PhotoAlbum.sharedInstance.getPhotoAlbumSize())
            averagePitch = totalPitch / CGFloat(PhotoAlbum.sharedInstance.getPhotoAlbumSize())
            averageYaw = totalYaw / CGFloat(PhotoAlbum.sharedInstance.getPhotoAlbumSize())
        }
    }
    
}
