//
//  ErrorMessage.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 14/12/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

/// Singleton class for showing error messages
class ErrorMessage: NSObject {
    
    static let sharedInstance = ErrorMessage()
    
    var alert = UIAlertController()
    
    // MARK: - Init
    
    fileprivate override init() {
        
    }
    
    // MARK: - Methods
    
    /// Displays the progress indicator and disables the user interaction
    func show(_ title: String, message: String) {
        if Platform.isSimulator {
            print(message)
        } else {
            alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: LocalizedKeys.okButton.description().localized, style: UIAlertActionStyle.default, handler: nil))
            gNavigationViewController?.topViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
