//
//  SettingsCell.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 08/11/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

class SettingsCell: UIView {
    var cellImage = UIImageView()
    var cellLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(cellImage)
        self.addSubview(cellLabel)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
