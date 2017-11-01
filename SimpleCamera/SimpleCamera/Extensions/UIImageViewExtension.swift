//
//  UIImageViewExtension.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 25/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func getTheFrameOfContent(contentMode: UIViewContentMode) -> CGRect {
        let img_opt = self.image
        if let img = img_opt {
            switch contentMode {
            case .scaleAspectFit:
                let imageSize: CGSize = img.size
                let scaleX: CGFloat = self.bounds.width / imageSize.width
                let scaleY: CGFloat = self.bounds.height / imageSize.height
                let imageScale: CGFloat = min(scaleX, scaleY)
                let scaledImageSize: CGSize = CGSize(width: imageSize.width*imageScale,
                                                     height: imageSize.height*imageScale)
                
                let imageFrame: CGRect = CGRect(x: (self.bounds.width - scaledImageSize.width) / 2,
                                                y: (self.bounds.height - scaledImageSize.height) / 2,
                                                width: scaledImageSize.width,
                                                height: scaledImageSize.height)
                return imageFrame
                
            default:
                fatalError("method getTheFrameOfContent not implemented yet for contentMode: \(contentMode)" )
                //return CGRect.zero
            }
        } else {
            return CGRect.zero
        }
    }
    
}
