//
//  BasicExtensions.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 06/12/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import Foundation

//MARK: Double extension

extension Double {
    /**
     Converting radians to degrees.
     */
    var toDegrees: Double {
        return 180 / .pi * self
    }
    
    /**
     Converting degrees to radians.
     */
    var toRadians : Double {
        return .pi / 180 * self
    }
}
