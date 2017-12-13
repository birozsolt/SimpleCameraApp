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

///UIViewController class which manage the video player screen.
class VideoPlayerViewController: UIViewController {
    private var avPlayer = AVPlayer()
    private var avPlayerLayer: AVPlayerLayer!
    
    private let invisibleButton = UIButton()
    private var playbackImage = UIImageView()
    
    private var timeObserver: AnyObject!
    private let timeRemainingLabel = UILabel()
    
    private let seekSlider = UISlider()
    private var playerRateBeforeSeek: Float = 0
    
    let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    ///The path of the video for the *avPlayer*.
    var videoUrl : URL?
    
    //MARK: - Init
    
    convenience init(videoUrl: URL) {
        self.init(nibName:nil, bundle:nil)
        self.videoUrl = videoUrl
    }
    
    //MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingIndicatorView.startAnimating()
        avPlayer.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.addSubview(invisibleButton)
        invisibleButton.addTarget(self, action: #selector(invisibleButtonTapped), for: .touchUpInside)
        
        invisibleButton.addSubview(playbackImage)
        playbackImage.autoSetDimensions(to: CGSize(width: 100, height: 100))
        playbackImage.autoCenterInSuperview()
        playbackImage.layer.cornerRadius = 50
        playbackImage.alpha = 0.7
        playbackImage.backgroundColor = .lightGray
        playbackImage.image = #imageLiteral(resourceName: "PauseVideo")
        playbackImage.isHidden = true
        
        let playerItem = AVPlayerItem(url: videoUrl!)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main) {
            (elapsedTime: CMTime) -> Void in
                self.observeTime(elapsedTime: elapsedTime)
        } as AnyObject

        timeRemainingLabel.textColor = .white
        view.addSubview(timeRemainingLabel)
        
        view.addSubview(seekSlider)
        seekSlider.addTarget(self, action: #selector(sliderBeganTracking), for: .touchDown)
        seekSlider.addTarget(self, action: #selector(sliderEndedTracking), for: [.touchUpInside, .touchUpOutside])
        seekSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        loadingIndicatorView.hidesWhenStopped = true
        view.addSubview(loadingIndicatorView)
        avPlayer.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        avPlayer.pause()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Layout subviews manually
        avPlayerLayer.frame = view.bounds
        invisibleButton.frame = view.bounds
        let controlsHeight: CGFloat = 30
        let controlsY: CGFloat = view.bounds.size.height - controlsHeight
        timeRemainingLabel.frame = CGRect(x: 5, y: controlsY, width: 60, height: controlsHeight)
        
        seekSlider.frame = CGRect(x: timeRemainingLabel.frame.origin.x + timeRemainingLabel.bounds.size.width,
                                  y: controlsY,
                                  width: view.bounds.size.width - timeRemainingLabel.bounds.size.width - 5,
                                  height: controlsHeight)
        
        loadingIndicatorView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "playbackLikelyToKeepUp" {
            if avPlayer.currentItem!.isPlaybackLikelyToKeepUp {
                loadingIndicatorView.stopAnimating()
            } else {
                loadingIndicatorView.startAnimating()
            }
        }
    }
    
    deinit {
        avPlayer.removeTimeObserver(timeObserver)
        avPlayer.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
    }
    
    //MARK: - Footage Time methodes
    
    private func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = CMTimeGetSeconds(avPlayer.currentItem!.duration) - elapsedTime
        timeRemainingLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
    }
    
    private func observeTime(elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        if duration.isFinite {
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
        }
    }
    
    //MARK: - Pause / play handler
    
    func invisibleButtonTapped(sender: UIButton){
        let playerIsPlaying = avPlayer.rate > 0
        if playerIsPlaying {
            avPlayer.pause()
            playbackImage.isHidden = false
        } else {
            avPlayer.play()
            playbackImage.isHidden = true
        }
    }
    
    //MARK: - Seeker methodes
    
    func sliderBeganTracking(slider: UISlider) {
        playerRateBeforeSeek = avPlayer.rate
        avPlayer.pause()
    }
    
    func sliderEndedTracking(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        
        avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, 100)) {
            (completed: Bool) -> Void in
            if self.playerRateBeforeSeek > 0 {
                self.avPlayer.play()
            }
        }
    }
    
    func sliderValueChanged(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
    }
}
