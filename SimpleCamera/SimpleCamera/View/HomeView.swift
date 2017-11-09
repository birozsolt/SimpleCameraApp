//
//  HomeView.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 31/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit
import PureLayout

protocol HomeViewProtocol {
    func cameraButtonTapped()
}

class HomeView: UIView {
    
    public var delegate : HomeViewProtocol?
    private var backgroundView = UIImageView()
    private var cameraButton = UIButton(type: UIButtonType.custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(backgroundView)
        self.insertSubview(cameraButton, aboveSubview: backgroundView)
        gNavigationViewController?.navigationBar.isHidden = true
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        backgroundView.autoPinEdgesToSuperviewEdges()
        backgroundView.backgroundColor = UIColor.brown
        
        cameraButton.autoAlignAxis(.horizontal, toSameAxisOf: backgroundView, withOffset: 10)
        cameraButton.autoSetDimensions(to: CGSize(width: 150, height: 60))
        cameraButton.layer.cornerRadius = 30
        cameraButton.autoAlignAxis(.vertical, toSameAxisOf: backgroundView)
        cameraButton.addTarget(self, action: #selector(startCamera), for: .touchUpInside)
        cameraButton.backgroundColor = UIColor.black
        cameraButton.setTitleColor(UIColor.white, for: .normal)
        cameraButton.setTitle("Camera", for: .normal)
        cameraButton.titleLabel?.font = UIFont(name: getFont(font: .bold), size: 30)
    }
    
    func startCamera() {
        delegate?.cameraButtonTapped()
    }
}
