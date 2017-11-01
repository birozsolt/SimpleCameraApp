//
//  SettingsViewController.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 31/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var settingsView = SettingsView(frame: CGRect.zero)
    
    override func loadView() {
        self.view = settingsView
    }
}
