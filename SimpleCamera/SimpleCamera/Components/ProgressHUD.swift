//
//  ProgressHUD.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 13/12/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

class ProgressHUD: NSObject {

    //static let sharedInstance = ProgressHUD()
    
    var backgroundView: UIView!
    let activityIndicator: UIActivityIndicatorView!
    var progressView : UIProgressView!
    let progressLabel : UILabel!
    
    // MARK: - Init
    
    override init() {
        backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.center = backgroundView.center
        activityIndicator.startAnimating()
        backgroundView.addSubview(activityIndicator)
        
        progressView = UIProgressView(progressViewStyle: .bar)
        backgroundView.addSubview(progressView)
        progressView.autoPinEdge(.top, to: .bottom, of: activityIndicator, withOffset: 5)
        progressView.autoAlignAxis(toSuperviewAxis: .vertical)
        progressView.autoSetDimension(.width, toSize: 100)
        progressView.trackTintColor = .gray
        progressView.progressTintColor = .white
        
        progressLabel = UILabel()
        backgroundView.addSubview(progressLabel)
        progressLabel.autoPinEdge(.top, to: .bottom, of: progressView, withOffset: 5)
        progressLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        progressLabel.textColor = .white
        progressLabel.alpha = 0.7
    }
    
    // MARK: - Methods
    
    /// Set the progress view to selected progress
    func setProgress(_ progress: Float, animated: Bool){
        progressView.setProgress(progress, animated: animated)
    }
    
    /// Set the progress label text to *text*
    func setTextLabel(_ text : String){
        progressLabel.text = text
    }
    
    /// Displays the progress indicator and disables the user interaction
    func show() {
        backgroundView.frame =  UIScreen.main.bounds
        self.activityIndicator.center = backgroundView.center
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 1.0
            gNavigationViewController?.topViewController!.view.addSubview(self.backgroundView)
        })
    }
    
    /// Hides the progress indicator and enables the user interaction
    func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 0.0
            self.backgroundView.removeFromSuperview()
        })
    }
}
