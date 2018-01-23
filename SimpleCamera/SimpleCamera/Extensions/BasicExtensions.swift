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
