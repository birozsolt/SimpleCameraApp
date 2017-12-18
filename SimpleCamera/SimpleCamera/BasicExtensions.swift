//
//  BasicExtensions.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 06/12/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import Foundation

//MARK: String extension

extension String {
    /**
     Returning the value of the String key from *Localizable.string* file.
     */
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

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
