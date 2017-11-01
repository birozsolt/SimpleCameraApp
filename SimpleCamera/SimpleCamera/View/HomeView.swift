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
    func settingsButtonTapped()
    func cameraButtonTapped()
}

class HomeView: UIView {
    
    public var delegate : HomeViewProtocol?
    private var backgroundView = UIImageView()
    private var settingsButton = UIButton(type: UIButtonType.custom)
    private var cameraButton = UIButton(type: UIButtonType.custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(backgroundView)
        self.insertSubview(settingsButton, aboveSubview: backgroundView)
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
        
        cameraButton.autoPinEdge(toSuperviewEdge: .top, withInset: 200)
        cameraButton.autoSetDimensions(to: CGSize(width: 150, height: 60))
        cameraButton.autoAlignAxis(.vertical, toSameAxisOf: backgroundView)
        cameraButton.addTarget(self, action: #selector(startCamera), for: .touchUpInside)
        cameraButton.backgroundColor = UIColor.black
        cameraButton.setTitleColor(UIColor.white, for: .normal)
        cameraButton.setTitle("Camera", for: .normal)
        
        
        
        settingsButton.autoPinEdge(.top, to: .bottom, of: cameraButton, withOffset: 60)
        settingsButton.autoSetDimensions(to: CGSize(width: 130, height: 50))
        settingsButton.autoAlignAxis(.vertical, toSameAxisOf: backgroundView)
        settingsButton.addTarget(self, action: #selector(showSettings), for: .touchUpInside)
        settingsButton.backgroundColor = UIColor.black
        settingsButton.setTitleColor(UIColor.white, for: .normal)
        settingsButton.setTitle("Settings", for: .normal)
    }
    
    func startCamera() {
        delegate?.cameraButtonTapped()
    }
    
    func showSettings(){
        delegate?.settingsButtonTapped()
    }
}
