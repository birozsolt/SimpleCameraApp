//
//  BasicExtensions.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 06/12/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

//MARK: CGFloat extension

extension CGFloat {
    /**
     Converting radians to degrees.
     */
    var toDegrees: CGFloat {
        return 180 / .pi * self
    }
    
    /**
     Converting degrees to radians.
     */
    var toRadians: CGFloat {
        return .pi / 180 * self
    }
}

//MARK: UIView extension

extension UIView {
    /**
     Move the view frame x-coordinate with *value*.
     - parameter xValue: The new value of the x-coordinate.
     */
    func moveXCoordinate(with xValue: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x + xValue, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    /**
     Change the view frame y-coordinate to the *values*.
     - parameter yValue: The new value of the y-coordinate
     */
    func setYCoordinate(to yValue: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x, y: yValue, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    /**
     Change the view frame x-coordinate to the *values*.
     - parameter yValue: The new value of the x-coordinate
     */
    func setXCoordinate(to xValue: CGFloat) {
        self.frame = CGRect(x: xValue, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    /**
     Change the marker color to *value*.
     - parameter value: The marker direction.
     */
    func changeMarkerColor(to color: MarkerColor) {
        switch color {
        case .green:
            self.backgroundColor = .green
        case .orange:
            self.backgroundColor = .orange
        }
    }
}

extension UIImage {
    private struct Motion{
        static var motionData : MotionData = MotionData(roll: 0, pitch: 0, yaw: 0)
    }
    
    var motionData: MotionData? {
        get{
            return objc_getAssociatedObject(self, &Motion.motionData) as? MotionData
        }
        set{
            if let unwrappedValue = newValue {
                objc_setAssociatedObject(self, &Motion.motionData, unwrappedValue as MotionData, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

struct Something {
    var totalRoll : CGFloat = 0
    var averageRoll : CGFloat = 0
    var totalPitch : CGFloat = 0
    var averagePitch : CGFloat = 0
    var totalYaw : CGFloat = 0
    var averageYaw : CGFloat = 0
}

var something = Something()

extension Array where Element: UIImage{
    var totalRoll : CGFloat{
        set{
            something.totalRoll += newValue
        }
        get{
            return something.totalRoll
        }
    }
    
    var averageRoll : CGFloat{
        get{
            return something.averageRoll
        }
    }
    
    var totalPitch : CGFloat{
        set{
            something.totalPitch += newValue
        }
        get{
            return something.totalPitch
        }
    }
    
    var averagePitch : CGFloat{
        get{
            return something.averagePitch
        }
    }
    
    var totalYaw : CGFloat{
        set{
            something.totalYaw += newValue
        }
        get{
            return something.totalYaw
        }
    }
    
    var averageYaw : CGFloat{
        get{
            return something.averageYaw
        }
    }
    
    mutating func addImage(_ newElement: Element) {
        self.append(newElement)
        if let motion = newElement.motionData {
            totalRoll = motion.roll
            totalPitch = motion.pitch
            totalYaw = motion.yaw
            something.averageRoll = something.totalRoll / CGFloat(self.count)
            something.averagePitch = something.totalPitch / CGFloat(self.count)
            something.averageYaw = something.totalYaw / CGFloat(self.count)
        }
    }
}
