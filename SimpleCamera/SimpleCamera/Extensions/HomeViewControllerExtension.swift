//
//  HomeViewControllerExtension.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 31/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

extension HomeViewController : HomeViewProtocol{
    func settingsButtonTapped() {
        settingsViewController = SettingsViewController()
        gNavigationViewController?.pushViewController(settingsViewController!, animated: true)
    }
    
    func cameraButtonTapped() {
        cameraViewController = CameraViewController()
        gNavigationViewController?.pushViewController(cameraViewController!, animated: true)
    }
}
