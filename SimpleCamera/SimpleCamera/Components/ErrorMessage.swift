//
//  ErrorMessage.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 14/12/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

/// Singleton class for showing error messages.
class ErrorMessage: NSObject {
    
    static let sharedInstance = ErrorMessage()
    
    // MARK: - Object Lifecycle
    
    fileprivate override init() {
        
    }
    
    // MARK: - Methods
    
    /**
     Displays the error message.
     - parameter title: The title of the ErrorMessage.
     - parameter message: The description of the ErrorMessage.
     */
    func show(_ title: LocalizedKeys, message: LocalizedKeys) {
        if Platform.isSimulator {
            print(message)
        } else {
            let alert = UIAlertController(title: title.description(), message: message.description(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: LocalizedKeys.okButton.description(), style: .default, handler: nil))
            gNavigationViewController?.topViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
