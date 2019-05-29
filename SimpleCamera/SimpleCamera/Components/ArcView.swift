//
//  ArcView.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 17/01/2018.
//  Copyright © 2018 Biro, Zsolt. All rights reserved.
//

import UIKit

class ArcView: UIView {
    let arcWidth: CGFloat = 10
    var counterColor: UIColor = UIColor.lightGray
    var startAngle: CGFloat = .pi / 2
    var endAngle: CGFloat = .pi / 2
}

class LeftArcView: ArcView {

    override func draw(_ rect: CGRect) {
        let arcCenter = CGPoint(x: bounds.width + 45, y: bounds.height / 2)
        let radius = bounds.width
        let path = UIBezierPath(arcCenter: arcCenter,
                                radius: radius - arcWidth,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        
        path.lineWidth = arcWidth
        counterColor.setStroke()
        path.stroke()
    }
}

class RightArcView: ArcView {
    
    override func draw(_ rect: CGRect) {
        let arcCenter = CGPoint(x: bounds.width - 135, y: bounds.height / 2)
        let radius = bounds.width
        let path = UIBezierPath(arcCenter: arcCenter,
                                radius: radius - arcWidth,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        
        path.lineWidth = arcWidth
        counterColor.setStroke()
        path.stroke()
    }
}
