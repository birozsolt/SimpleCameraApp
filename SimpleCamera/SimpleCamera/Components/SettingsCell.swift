//
//  SettingsCell.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 08/11/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

/// Basic class for *SettingsView* cells.
class SettingsCell: UIView {
    var cellImage = UIImageView()
    var cellLabel = UILabel()
    
    //MARK: - Object Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.addSubview(cellImage)
        self.addSubview(cellLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
