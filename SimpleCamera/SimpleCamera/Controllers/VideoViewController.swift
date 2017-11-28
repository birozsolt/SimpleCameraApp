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
    
    init(album: [UIImage]) {
        self.album = album
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func buildButtonTapped(sender: AnyObject) {
        if let camera = camera,
            let album = album {
            
            self.timeLapseBuilder = TimeLapseBuilder(photoArray: videos)
            self.timeLapseBuilder!.build(
                { (progress: NSProgress) in
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
