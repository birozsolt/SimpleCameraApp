//
//  Globals.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 25/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

var gHomeViewController: HomeViewController?
var gNavigationViewController : UINavigationController?

enum Fonts {
    case light
    case bold
}

func getFont(font : Fonts) -> String {
    switch font {
    case .light:
        return "Saker Sans Light PERSONAL USE"
    case .bold:
        return "Saker Sans Bold PERSONAL USE"
    }
}

enum CameraSettings : String {
    case Brightness
    case Exposure
    case Flash
    
    static var count: Int { return CameraSettings.Flash.hashValue + 1}
}

extension Double {
    var toDegrees: Double {
        return 180 / .pi * self
    }
}
