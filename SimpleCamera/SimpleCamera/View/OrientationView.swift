//
//  OrientationView.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 15/11/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

/**
 Orientation slider values.
 
 - increase: An increasing slider value.
 - decrease: A decreasing slider value.
 */
enum SliderValue {
    case increase
    case decrease
}

/// UIView class for setting the orientation view
class OrientationView: UIView {
    
    /// Horizontal slider variable.
    var horizontalSlider = UISlider()
    
    /// Vertical slider variable.
    var verticalSlider = UISlider()
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(horizontalSlider)
        self.addSubview(verticalSlider)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup funcions for views
    
    /// It setting up orintation view components.
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
    
    /**
     Setting the horizontal slider value.
     - parameter value: Setting the horizontal slider value to a *SliderValue*
     */
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
    
    /**
     Setting the vertical slider value.
     - parameter value: Setting the horizontal slider value to a *SliderValue*
     */
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
