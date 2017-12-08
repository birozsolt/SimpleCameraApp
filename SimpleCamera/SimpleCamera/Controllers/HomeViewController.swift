//
//  HomeViewController.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 25/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var cameraViewController : CameraViewController!
    var homeView = HomeView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        self.view = homeView
        homeView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension HomeViewController : HomeViewProtocol{
    
    func cameraButtonTapped() {
        cameraViewController = CameraViewController()
        gNavigationViewController?.pushViewController(cameraViewController, animated: true)
    }
}
