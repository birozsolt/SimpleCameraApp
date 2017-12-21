//
//  HomeView.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 31/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

/// HomeView protocol used for implementing button actions.
protocol HomeViewProtocol {
    func cameraButtonTapped()
}

/// UIView class for setting the home screen view
class HomeView: UIView {
    
    /// HomeViewProtocol delegate variable.
    public var delegate : HomeViewProtocol?
    
    //MARK: - View variables
    
    /// The background view of the *HomeView*.
    private var backgroundView = UIImageView()
    
    //MARK: - Button variables
    
    /// The camera button variable.
    private var cameraButton = UIButton(type: UIButtonType.custom)
    
    //MARK: - Object Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(backgroundView)
        insertSubview(cameraButton, aboveSubview: backgroundView)
        
        gNavigationViewController?.navigationBar.isHidden = true
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup funcion for view
    
    /// It setting up home screen views.
    private func setupViews(){
        backgroundView.autoPinEdgesToSuperviewEdges()
        backgroundView.backgroundColor = UIColor.brown
        
        cameraButton.autoAlignAxis(.horizontal, toSameAxisOf: backgroundView, withOffset: 10)
        cameraButton.autoAlignAxis(.vertical, toSameAxisOf: backgroundView)
        cameraButton.autoSetDimensions(to: CGSize(width: 150, height: 60))
        cameraButton.layer.cornerRadius = 30
        cameraButton.addTarget(self, action: #selector(startCamera), for: .touchUpInside)
        cameraButton.backgroundColor = UIColor.black
        cameraButton.setTitleColor(UIColor.white, for: .normal)
        cameraButton.setTitle(LocalizedKeys.camera.description(), for: .normal)
        cameraButton.titleLabel?.font = getFont(.bold, withSize: 30)
    }
    
    //MARK: - Button touch handler function
    
    /**
     It is called after touching the camera button.
     - Implemented in the class which adopted *HomeViewProtocol* .
     */
    func startCamera() {
        delegate?.cameraButtonTapped()
    }
}
