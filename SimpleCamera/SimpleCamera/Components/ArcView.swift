//
//  ArcView.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 17/01/2018.
//  Copyright © 2018 Biro, Zsolt. All rights reserved.
//

import UIKit

class LeftArcView: UIView {
    
    private struct Constants {
        static let arcWidth: CGFloat = 10
    }
    
    var counterColor: UIColor = UIColor.lightGray
    var startAngle: CGFloat = .pi / 2
    var endAngle: CGFloat = .pi / 2
    
    override func draw(_ rect: CGRect) {
        
        let arcCenter = CGPoint(x: bounds.width + 90 , y: bounds.height / 2)
        let radius = bounds.width
        
        let path = UIBezierPath(arcCenter: arcCenter,
                                radius: radius - Constants.arcWidth,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        
        path.lineWidth = Constants.arcWidth
        counterColor.setStroke()
        path.stroke()
    }
}

class RightArcView: UIView {
    
    private struct Constants {
        static let arcWidth: CGFloat = 10
    }
    
    var counterColor: UIColor = UIColor.lightGray
    var startAngle: CGFloat = .pi / 2
    var endAngle: CGFloat = .pi / 2
    
    override func draw(_ rect: CGRect) {
        
        let arcCenter = CGPoint(x: bounds.width - 270 , y: bounds.height / 2)
        let radius = bounds.width
        
        let path = UIBezierPath(arcCenter: arcCenter,
                                radius: radius - Constants.arcWidth,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        
        path.lineWidth = Constants.arcWidth
        counterColor.setStroke()
        path.stroke()
    }
}

