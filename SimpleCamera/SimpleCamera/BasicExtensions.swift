//
//  BasicExtensions.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 06/12/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

//MARK: Double extension

extension Double {
    /**
     Converting radians to degrees.
     */
    var toDegrees: Double {
        return 180 / .pi * self
    }
}

//MARK: CGFloat extension

extension CGFloat {
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
     Move the view frame y-coordinate with *value*.
     - parameter yValue: The new value of the y-coordinate.
     */
    func moveYCoordinate(with yValue: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y + yValue, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    /**
     Move the view frame x-coordinate with *value*.
     - parameter xValue: The new value of the x-coordinate.
     */
    func moveXCoordinate(with xValue: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x + xValue, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    /**
     Change the view frame x-coordinate to the *values*.
     - parameter xValue: The new value of the x-coordinate
     */
    func setXCoordinate(to xValue: CGFloat) {
        self.frame = CGRect(x: xValue, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
    }
}
