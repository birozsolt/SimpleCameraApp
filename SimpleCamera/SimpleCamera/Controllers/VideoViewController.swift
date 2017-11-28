//
//  VideoViewController.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 28/11/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit

class BuildTimelapseViewController: UIViewController {
    private var resolutionSegmentedControl: UISegmentedControl!
    private var speedSlider: UISlider!
    private var removeFisheyeSlider: UISwitch!
    
    var album: [UIImage]?
    var timeLapseBuilder: TimeLapseBuilder?
    
    convenience init(album: [UIImage]) {
        self.init(nibName:nil, bundle:nil)
        self.album = album
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func buildButtonTapped(sender: AnyObject) {
        if let album = self.album {
            self.timeLapseBuilder = TimeLapseBuilder(photoArray: album)
            self.timeLapseBuilder!.build(
                { (progress: Progress) in
                    NSLog("Progress: \(progress.completedUnitCount) / \(progress.totalUnitCount)")
            },
                success: { url in
                    NSLog("Output written to \(url)")
                    
            },
                failure: { error in
                    NSLog("failure: \(error)")
            }
            )
        }
    }
}
