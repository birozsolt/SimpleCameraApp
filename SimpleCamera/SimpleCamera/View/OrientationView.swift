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

/**
 Orientation marker colors.
 
 - green: Green background.
 - orange: Orange background.
 */
enum MarkerColor{
    case green
    case orange
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
        horizontalView.addSubview(verticalRightView)
        backgroundView.insertSubview(leftArcView, belowSubview: horizontalView)
        backgroundView.insertSubview(rightArcView, belowSubview: horizontalView)
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
        backgroundView.alpha = 0.5
        
        horizontalView.autoSetDimensions(to: CGSize(width: 170, height: 6))
        horizontalView.autoAlignAxis(.horizontal, toSameAxisOf: self, withOffset: 0)
        horizontalView.autoAlignAxis(toSuperviewAxis: .vertical)
        horizontalView.backgroundColor = .lightGray
        
        setupHorizontalMarkerViews(for: horizontalLeftMarker)
        horizontalLeftMarker.autoPinEdge(toSuperviewEdge: .left)
        setupHorizontalMarkerViews(for: horizontalRightMarker)
        horizontalRightMarker.autoPinEdge(toSuperviewEdge: .right)
        
        verticalLeftView.autoAlignAxis(.vertical, toSameAxisOf: horizontalView, withOffset: -15)
        setupViews(for: verticalLeftView)
        verticalRightView.autoAlignAxis(.vertical, toSameAxisOf: horizontalView, withOffset: 15)
        setupViews(for: verticalRightView)
        
        setupVerticalMarkerViews(for: verticalLeftMarker)
        setupVerticalMarkerViews(for: verticalRightMarker)
        
        setupArcViews(for: leftArcView, startAngle: CGFloat(133).toRadians, endAngle: CGFloat(227).toRadians)
        leftArcView.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: -90)
        setupArcViews(for: rightArcView, startAngle: CGFloat(313).toRadians, endAngle: CGFloat(47).toRadians)
        rightArcView.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: 90)
    }
    
    /// It setting up the vertical view components.
    func setupViews(for verticalView: UIView){
        verticalView.autoSetDimensions(to: CGSize(width: 10, height: 90))
        verticalView.autoAlignAxis(toSuperviewAxis: .horizontal)
        verticalView.backgroundColor = .lightGray
    }
    
    /// It setting up the vertical marker view components.
    func setupVerticalMarkerViews(for marker: UIView){
        marker.autoSetDimensions(to: CGSize(width: 10, height: 6))
        marker.autoCenterInSuperview()
        marker.backgroundColor = .orange
    }
    
    /// It setting up the horizontal marker view components.
    func setupHorizontalMarkerViews(for marker: UIView){
        marker.autoSetDimensions(to: CGSize(width: 10, height: 6))
        marker.autoAlignAxis(.horizontal, toSameAxisOf: self, withOffset: 0)
        marker.backgroundColor = .orange
    }
    
    /// It setting up the vertical view components.
    func setupArcViews(for arcView: ArcView, startAngle: CGFloat, endAngle: CGFloat){
        arcView.autoSetDimensions(to: CGSize(width: 90, height: 90))
        arcView.autoAlignAxis(toSuperviewAxis: .horizontal)
        arcView.startAngle = startAngle
        arcView.endAngle = endAngle
        arcView.backgroundColor = .clear
    }
    
    /**
     Move the marker to the given of *angle*.
     - parameter angle: The marker tilt angle.
     */
    func updateVerticalMarker(for angle : CGFloat){
        var zoomAngle = angle / 2
        
        if zoomAngle > 90 {
            zoomAngle = 90
        } // stop at the end
        if zoomAngle < 0{
            zoomAngle = 0
        } // stop at the other end
        
        if zoomAngle > 40 && zoomAngle < 44 {
            verticalLeftMarker.changeMarkerColor(to: .green)
            verticalRightMarker.changeMarkerColor(to: .green)
        } else {
            verticalLeftMarker.changeMarkerColor(to: .orange)
            verticalRightMarker.changeMarkerColor(to: .orange)
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.verticalLeftMarker.setYCoordinate(to: zoomAngle)
            self.verticalRightMarker.setYCoordinate(to: zoomAngle)
        })
    }
    
    /**
     Move the marker to the given of *angle*.
     - parameter angle: The marker roll angle.
     */
    func updateHorizontalMarker(to angle: CGFloat) {
        var zoomAngle = angle
        
        if zoomAngle > 34 {
            zoomAngle = 34
        } // stop at the end
        if zoomAngle < -34{
            zoomAngle = -34
        } // stop at the other end
        
        if zoomAngle > -1 && zoomAngle < 1 {
            horizontalLeftMarker.changeMarkerColor(to: .green)
            horizontalRightMarker.changeMarkerColor(to: .green)
        } else {
            horizontalLeftMarker.changeMarkerColor(to: .orange)
            horizontalRightMarker.changeMarkerColor(to: .orange)
        }

        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.horizontalView.transform = CGAffineTransform(rotationAngle: zoomAngle.toRadians)
        })
    }
}
