//
//  Fonts.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 12/02/2018.
//  Copyright © 2018 Biro, Zsolt. All rights reserved.
//

import UIKit

/**
 Font types used for texts.
 
 - light: A regular font.
 - bold: A bold font.
 */
enum Fonts {
    case light
    case bold
    
    /**
     Returns a font object in the specified type and size.
     - parameter size: The size of the font.
     
     - returns: A "Saker Sans" font in the specified *type* and *size* .
     */
    func withSize(_ size: CGFloat) -> UIFont {
        switch self {
        case .light:
            let font = UIFont(name: LocalizedKeys.lightFont.localized, size: size)
            return font ?? UIFont.systemFont(ofSize: size)
        case .bold:
            let font = UIFont(name: LocalizedKeys.boldFont.localized, size: size)
            return font ?? UIFont.systemFont(ofSize: size)
        }
    }
}
