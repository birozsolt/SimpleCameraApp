//
//  Globals.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 25/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

///NavigationViewController reference of the project.
var gNavigationViewController : UINavigationController?

///Contains images for creating timelapse video.
var imageArray = [UIImage]()

/**
 Font types used for texts.
 
 - light: A regular font.
 - bold: A bold font.
 */
enum Fonts {
    case light, bold
}

/**
 Returns a font object in the specified type and size.
 
 - parameter font: The type of the font.
 - parameter size: The size of the font.
 
 - returns: A "Saker Sans" font in the specified *type* and *size* .
 */
func getFont(_ font : Fonts, withSize size: CGFloat) -> UIFont {
    switch font {
    case .light:
        let font = UIFont(name: LocalizedKeys.lightFont.description().localized, size: size)
        return font ?? UIFont.systemFont(ofSize: size)
    case .bold:
        let font = UIFont(name: LocalizedKeys.boldFont.description().localized, size: size)
        return font ?? UIFont.systemFont(ofSize: size)
    }
}

/// Struct which determines if the app running on a ios simulator, or device.
struct Platform {
    ///Returns *true* if the app running on a ios simulator, *false* if runs on a device.
    static let isSimulator: Bool = {
        var isSim = false
        
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        
        return isSim
    }()
}

///Contains the localized keys from *Localizable.string* file.
enum LocalizedKeys: String {
    case titleError
    case okButton
    case cancelButton
    case videoPlayerError
    case noCamerasAvailable
    case timeLapseBuildError
    case referenceFrameError
    case motionServiceError
    case videoName
    case videoExt
    case photoSaveError
    case lightFont
    case boldFont
    
    func description() -> String {
        switch self {
        case .titleError: return "titleError"
        case .okButton: return "okButton"
        case .cancelButton: return "cancelButton"
        case .videoPlayerError: return "videoPlayerError"
        case .noCamerasAvailable: return "noCamerasAvailable"
        case .timeLapseBuildError: return "timeLapseBuildError"
        case .referenceFrameError: return "referenceFrameError"
        case .motionServiceError: return "motionServiceError"
        case .videoName: return "videoName"
        case .videoExt: return "videoExt"
        case .photoSaveError: return "photoSaveError"
        case .lightFont: return "lightFont"
        case .boldFont: return "boldFont"
        }
    }
}
