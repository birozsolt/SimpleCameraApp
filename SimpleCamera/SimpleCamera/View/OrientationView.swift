//
//  OrientationView.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 15/11/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

/**
 Orientation marker values.
 
 - up: An increasing marker value.
 - down: A decreasing marker value.
 */
enum MarkerValue {
    case up
    case down
}

/// UIView class for setting the orientation view
class OrientationView: UIView {
    
    private let backgroundView = UIView()
    
    private let verticalLeftView = UIView()
    private let verticalRightView = UIView()
    
    private let verticalLeftMarker = UIView()
    private let verticalRightMarker = UIView()
    
    private let horizontalView = UIView()
    private let horizontalLeftMarker = UIView()
    private let horizontalRightMarker = UIView()
    
    private let leftArcView = LeftArcView()
    private let rightArcView = RightArcView()
    
    private var max = CGFloat()
    private var min = CGFloat()
    
    //MARK: - Object Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backgroundView)
        backgroundView.addSubview(horizontalView)
        horizontalView.addSubview(horizontalLeftMarker)
        horizontalView.addSubview(horizontalRightMarker)
        backgroundView.addSubview(verticalLeftView)
        backgroundView.addSubview(verticalRightView)
        backgroundView.addSubview(leftArcView)
        backgroundView.addSubview(rightArcView)
        verticalLeftView.addSubview(verticalLeftMarker)
        verticalRightView.addSubview(verticalRightMarker)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup funcions for views
    
    /// It setting up orientation view components.
    private func setupViews(){
        
        backgroundView.autoPinEdgesToSuperviewEdges()
        backgroundView.backgroundColor = .clear
        
        horizontalView.autoSetDimensions(to: CGSize(width: 170, height: 10))
        horizontalView.autoAlignAxis(.horizontal, toSameAxisOf: self, withOffset: 0)
        horizontalView.autoAlignAxis(toSuperviewAxis: .vertical)
        horizontalView.alpha = 0.5
        horizontalView.backgroundColor = .lightGray
        
        horizontalLeftMarker.autoSetDimensions(to: CGSize(width: 10, height: 10))
        horizontalLeftMarker.autoPinEdge(toSuperviewEdge: .left)
        horizontalLeftMarker.autoAlignAxis(.horizontal, toSameAxisOf: self, withOffset: 0)
        horizontalLeftMarker.backgroundColor = .orange

        horizontalRightMarker.autoSetDimensions(to: CGSize(width: 10, height: 10))
        horizontalRightMarker.autoAlignAxis(.horizontal, toSameAxisOf: self, withOffset: 0)
        horizontalRightMarker.autoPinEdge(toSuperviewEdge: .right)
        horizontalRightMarker.backgroundColor = .orange
        
        verticalLeftView.autoSetDimensions(to: CGSize(width: 10, height: 180))
        verticalLeftView.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: -30)
        verticalLeftView.autoAlignAxis(toSuperviewAxis: .horizontal)
        verticalLeftView.alpha = 0.5
        verticalLeftView.backgroundColor = .lightGray
        
        verticalLeftMarker.autoSetDimensions(to: CGSize(width: 10, height: 10))
        verticalLeftMarker.autoCenterInSuperview()
        verticalLeftMarker.backgroundColor = .orange
        
        verticalRightView.autoSetDimensions(to: CGSize(width: 10, height: 180))
        verticalRightView.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: 30)
        verticalRightView.autoAlignAxis(toSuperviewAxis: .horizontal)
        verticalRightView.alpha = 0.5
        verticalRightView.backgroundColor = .lightGray
        
        verticalRightMarker.autoSetDimensions(to: CGSize(width: 10, height: 10))
        verticalRightMarker.autoCenterInSuperview()
        verticalRightMarker.backgroundColor = .orange
        
        leftArcView.autoSetDimensions(to: CGSize(width: 180, height: 190))
        leftArcView.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: -90)
        leftArcView.autoAlignAxis(toSuperviewAxis: .horizontal)
        leftArcView.startAngle = CGFloat(148).toRadians
        leftArcView.endAngle = CGFloat(212).toRadians
        leftArcView.alpha = 0.5
        leftArcView.backgroundColor = .clear
        
        rightArcView.autoSetDimensions(to: CGSize(width: 180, height: 190))
        rightArcView.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: 90)
        rightArcView.autoAlignAxis(toSuperviewAxis: .horizontal)
        rightArcView.startAngle = CGFloat(328).toRadians
        rightArcView.endAngle = CGFloat(32).toRadians
        rightArcView.alpha = 0.5
        rightArcView.backgroundColor = .clear

        min = verticalLeftView.frame.origin.y
        max = verticalLeftView.frame.origin.y + 170
    }
    
    /**
     Move the marker to the direction of *value*.
     - parameter value: The marker direction.
     */
    func moveVerticalMarker(value: MarkerValue) {
        
        /// Start animationg the markers/
        func animate(value: MarkerValue){
            switch value {
            case .up:
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                    self.verticalLeftMarker.moveYCoordinate(with: -5)
                    self.verticalRightMarker.moveYCoordinate(with: -5)
                })
            case .down:
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                    self.verticalLeftMarker.moveYCoordinate(with: 5)
                    self.verticalRightMarker.moveYCoordinate(with: 5)
                })
            }
        }
        
        /// Stop animating the markers in the direction down
        func stopAnimationDown(value: MarkerValue){
            switch value {
            case .up:
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                    self.verticalLeftMarker.moveYCoordinate(with: -5)
                    self.verticalRightMarker.moveYCoordinate(with: -5)
                })
            case .down:
                self.verticalLeftMarker.moveYCoordinate(with: 0)
                self.verticalRightMarker.moveYCoordinate(with: 0)
            }
        }
        
        /// Stop animating the markers in the direction up
        func stopAnimationUp(value: MarkerValue){
            switch value {
            case .up:
                self.verticalLeftMarker.moveYCoordinate(with: 0)
                self.verticalRightMarker.moveYCoordinate(with: 0)
                
            case .down:
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                    self.verticalLeftMarker.moveYCoordinate(with: 5)
                    self.verticalRightMarker.moveYCoordinate(with: 5)
                })
            }
        }

        if verticalLeftMarker.frame.origin.y < max && verticalLeftMarker.frame.origin.y > min{
            animate(value: value)
        } else if verticalLeftMarker.frame.origin.y >= max {
            stopAnimationDown(value: value)
        } else if verticalLeftMarker.frame.origin.y <= min {
            stopAnimationUp(value: value)
        }
    }
    
    /**
     Move the marker to the direction of *value*.
     - parameter value: The marker direction.
     */
    func moveHorizontalMarker(value: MarkerValue) {
        /// Start animationg the markers/
        func animate(value: MarkerValue){
            switch value {
            case .up:
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                    self.horizontalView.transform = CGAffineTransform(rotationAngle: CGFloat(5).toRadians)
                })
            case .down:
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                    self.horizontalView.transform = CGAffineTransform(rotationAngle: CGFloat(-5).toRadians)
                })
            }
        }
        
        /// Stop animating the markers in the direction down
        func stopAnimationDown(value: MarkerValue){
            switch value {
            case .up:
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                    self.horizontalView.transform = CGAffineTransform(rotationAngle: CGFloat(5).toRadians)
                })
            case .down:
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                    self.horizontalView.transform = CGAffineTransform(rotationAngle: CGFloat(0).toRadians)
                })
            }
        }
        
        /// Stop animating the markers in the direction up
        func stopAnimationUp(value: MarkerValue){
            switch value {
            case .up:
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                    self.horizontalView.transform = CGAffineTransform(rotationAngle: CGFloat(0).toRadians)
                })
            case .down:
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                    self.horizontalView.transform = CGAffineTransform(rotationAngle: CGFloat(-5).toRadians)
                })
            }
        }
        
        if horizontalLeftMarker.frame.origin.x < max && horizontalLeftMarker.frame.origin.y > min{
            animate(value: value)
        } else if horizontalLeftMarker.frame.origin.y >= max {
            stopAnimationDown(value: value)
        } else if horizontalLeftMarker.frame.origin.y <= min {
            stopAnimationUp(value: value)
        }
    }
}
