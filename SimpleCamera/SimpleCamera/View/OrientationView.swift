//
//  OrientationView.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 15/11/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

enum SliderValue {
    case increase
    case decrease
}

class OrientationView: UIView {
    
    var horizontalSlider = UISlider()
    var verticalSlider = UISlider()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(horizontalSlider)
        self.addSubview(verticalSlider)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        
        verticalSlider.autoSetDimensions(to: CGSize(width: 5, height: 100))
        verticalSlider.autoAlignAxis(toSuperviewAxis: .vertical)
        verticalSlider.autoCenterInSuperview()
        verticalSlider.maximumValue = 100
        verticalSlider.minimumValue = 0
        verticalSlider.tintColor = UIColor.black
        verticalSlider.backgroundColor = UIColor.black
        verticalSlider.setValue(50, animated: true)
        verticalSlider.isUserInteractionEnabled = false
        verticalSlider.setThumbImage(#imageLiteral(resourceName: "SliderThumbImage"), for: .normal)
        
        horizontalSlider.autoSetDimensions(to: CGSize(width: 100, height: 5))
        horizontalSlider.autoAlignAxis(toSuperviewAxis: .horizontal)
        horizontalSlider.autoCenterInSuperview()
        horizontalSlider.maximumValue = 100
        horizontalSlider.minimumValue = 0
        horizontalSlider.tintColor = UIColor.black
        horizontalSlider.backgroundColor = UIColor.black
        horizontalSlider.setValue(50, animated: true)
        horizontalSlider.isUserInteractionEnabled = false
        horizontalSlider.setThumbImage(#imageLiteral(resourceName: "SliderThumbImage"), for: .normal)
    }
    
    func setHorizontalSlider(to value: SliderValue){
        switch value {
        case .increase:
            DispatchQueue.main.async {
                self.horizontalSlider.setValue(self.horizontalSlider.value + 5, animated: true)
            }
        case .decrease:
            DispatchQueue.main.async {
                self.horizontalSlider.setValue(self.horizontalSlider.value - 5, animated: true)
            }
        }
    }
    
    func setVerticalSlider(to value: SliderValue){
        switch value {
        case .increase:
            DispatchQueue.main.async {
                self.verticalSlider.setValue(self.verticalSlider.value + 5, animated: true)
            }
        case .decrease:
            DispatchQueue.main.async {
                self.verticalSlider.setValue(self.verticalSlider.value - 5, animated: true)
            }
        }
    }
}
