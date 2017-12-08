//
//  VideoPlayerViewController.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 28/11/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoPlayerViewController: UIViewController {
    var avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    var videoUrl : URL?
    
    convenience init(videoUrl: URL) {
        self.init(nibName:nil, bundle:nil)
        self.videoUrl = videoUrl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        avPlayer.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        let playerItem = AVPlayerItem(url: videoUrl!)
        avPlayer.replaceCurrentItem(with: playerItem)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        avPlayer.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Layout subviews manually
        avPlayerLayer.frame = view.bounds
    }
}
