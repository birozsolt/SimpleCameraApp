//
//  LoadingBox.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 25/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

/// Singleton class for showing a hourglass
class LoadingBox: NSObject {
    
    static let sharedInstance = LoadingBox()
    
    private var backgroundView: UIView!
    private let activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Object Lifecycle
    
    fileprivate override init() {
        backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.center = backgroundView.center
        activityIndicator.startAnimating()
        
        backgroundView.addSubview(activityIndicator)
    }
    
    // MARK: - Methods
    
    /// Displays the progress indicator and disables the user interaction
    func block() {
        backgroundView.frame =  UIScreen.main.bounds
        activityIndicator.center = backgroundView.center
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 1.0
            gNavigationViewController?.topViewController!.view.addSubview(self.backgroundView)
        })
    }
    
    /// Hides the progress indicator and enables the user interaction
    func unblock() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 0.0
            self.backgroundView.removeFromSuperview()
        })
    }
}
