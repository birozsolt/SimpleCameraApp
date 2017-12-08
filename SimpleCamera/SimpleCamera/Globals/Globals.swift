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
        let font = UIFont(name: "Saker Sans Light PERSONAL USE", size: size)
        return font ?? UIFont.systemFont(ofSize: size)
    case .bold:
        let font = UIFont(name: "Saker Sans Bold PERSONAL USE", size: size)
        return font ?? UIFont.systemFont(ofSize: size)
    }
}
