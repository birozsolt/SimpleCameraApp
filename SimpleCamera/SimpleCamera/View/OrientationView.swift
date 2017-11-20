//
//  OrientationView.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 15/11/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

protocol OrientationViewProtocol {
    func moveHorizontalSlider(to direction: SliderMoves)
    func moveVerticalSlider(to direction: SliderMoves)
}

class OrientationView: UIView {
    
    var delegate : OrientationViewProtocol?
    var horizontalLine = UIView()
    var horizontalSlider = UIView()
    
    var verticalLine = UIView()
    var verticalSlider = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(horizontalLine)
        horizontalLine.addSubview(horizontalSlider)
        self.addSubview(verticalLine)
        verticalLine.addSubview(verticalSlider)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        horizontalSlider.autoSetDimensions(to: CGSize(width: 5, height: 5))
        horizontalSlider.autoCenterInSuperview()
        horizontalSlider.autoAlignAxis(toSuperviewAxis: .horizontal)
        horizontalSlider.backgroundColor = UIColor.orange
        
        verticalSlider.autoSetDimensions(to: CGSize(width: 5, height: 5))
        verticalSlider.autoAlignAxis(toSuperviewAxis: .vertical)
        verticalSlider.autoCenterInSuperview()
        verticalSlider.backgroundColor = UIColor.orange
        
        horizontalLine.autoSetDimensions(to: CGSize(width: 100, height: 5))
        horizontalLine.autoCenterInSuperview()
        horizontalLine.autoAlignAxis(toSuperviewAxis: .horizontal)
        horizontalLine.backgroundColor = UIColor.black
        horizontalLine.alpha = 0.6
        
        verticalLine.autoSetDimensions(to: CGSize(width: 5, height: 100))
        verticalLine.autoCenterInSuperview()
        verticalLine.autoAlignAxis(toSuperviewAxis: .vertical)
        verticalLine.backgroundColor = UIColor.black
        verticalLine.alpha = 0.6
    }
}
