//
//  UIColorEx.swift
//  LiquidLoading
//
//  Created by Takuma Yoshida on 2015/08/21.
//  Copyright (c) 2015年 yoavlt. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    var alpha: CGFloat {
        get {
            return self.cgColor.alpha
        }
    }

    func alpha(alpha: CGFloat) -> UIColor {
        return UIColor(red: 1, green: 1, blue: 1, alpha: alpha)
    }
    
    func white(scale: CGFloat) -> UIColor {
        return UIColor(
            red: 1 * scale,
            green: 1 * scale,
            blue: 1 * scale,
            alpha: 1.0
        )
    }
}
