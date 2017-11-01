//
//  SettingsView.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 31/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit
import PureLayout

class SettingsView: UIView {
    
    private var backgroundView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(backgroundView)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundView.autoPinEdgesToSuperviewEdges()
        backgroundView.backgroundColor = UIColor.cyan
    }
}
