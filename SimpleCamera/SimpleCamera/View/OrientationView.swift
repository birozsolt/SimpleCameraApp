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
    
    //MARK: - Object Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(horizontalSlider)
        addSubview(verticalSlider)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup funcions for views
    
    /// It setting up orientation view components.
    private func setupViews(){
        commonSliderSetups(for: verticalSlider)
        verticalSlider.setThumbImage(#imageLiteral(resourceName: "SliderThumbImage"), for: .normal)
        verticalSlider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        
        commonSliderSetups(for: horizontalSlider)
        horizontalSlider.setThumbImage(#imageLiteral(resourceName: "SliderThumbImage"), for: .normal)
    }
    
    /**
     Setting an *UISlider* attributes.
     - parameter slider: Setting the *slider* attributes to the requiered values for *OrientationView*.
     */
    private func commonSliderSetups(for slider : UISlider) {
        slider.autoSetDimensions(to: CGSize(width: 100, height: 5))
        slider.autoAlignAxis(toSuperviewAxis: .horizontal)
        slider.autoCenterInSuperview()
        slider.maximumValue = 1.0
        slider.minimumValue = 0.0
        slider.tintColor = .black
        slider.backgroundColor = .black
        slider.maximumTrackTintColor = .black
        slider.minimumTrackTintColor = .black
        slider.setValue(0.5, animated: true)
        slider.isUserInteractionEnabled = false
    }
    
    /**
     Setting the horizontal slider value.
     - parameter value: Setting the horizontal slider value to a *SliderValue*
     */
    func setHorizontalSlider(to value: SliderValue){
        switch value {
        case .increase:
            DispatchQueue.main.async {
                let value = self.horizontalSlider.value + 0.05
                self.horizontalSlider.setValue(value, animated: true)
            }
        case .decrease:
            DispatchQueue.main.async {
                let value = self.horizontalSlider.value - 0.05
                self.horizontalSlider.setValue(value, animated: true)
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
                let value = self.verticalSlider.value + 0.05
                self.verticalSlider.setValue(value, animated: true)
            }
        case .decrease:
            DispatchQueue.main.async {
                let value = self.verticalSlider.value + 0.05
                self.verticalSlider.setValue(value, animated: true)
            }
        }
    }
}
