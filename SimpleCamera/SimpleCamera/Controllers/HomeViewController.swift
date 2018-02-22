//
//  HomeViewController.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 25/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

///UIViewController class for managing the home screen.
class HomeViewController: UIViewController {
    
    ///The *CameraViewController* instance for opening the camera screen.
    fileprivate var cameraViewController : CameraViewController!
    
    ///The view that the *HomeViewController* manages.
    var homeView = HomeView(frame: CGRect.zero)
    
    override var prefersStatusBarHidden: Bool {return true}
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gNavigationViewController?.navigationBar.backgroundColor = .darkGray
        gNavigationViewController?.navigationBar.barTintColor = .darkGray
        gNavigationViewController?.isNavigationBarHidden = true
    }
    
    override func loadView() {
        view = homeView
        homeView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - HomeViewProtocol

extension HomeViewController : HomeViewProtocol{
    
    /**
     Open *CameraViewController* after tapped.
     */
    func cameraButtonTapped() {
        cameraViewController = CameraViewController()
        gNavigationViewController?.pushViewController(cameraViewController, animated: true)
    }
}
