//
//  VideoPlayerViewController.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 28/11/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import UIKit
import Player
import AVFoundation

class VideoPlayerViewController: UIViewController {
    
    fileprivate let player = Player()
    fileprivate let timeRemainingLabel = UILabel()
    fileprivate let playbackProgressView = UIProgressView()
    fileprivate let playbackImage = UIImageView()
    
    override var prefersStatusBarHidden: Bool {return true}
    
    ///The path of the video for the *videoPlayer*.
    fileprivate var videoUrl: URL?
    
    // MARK: - Object Lifecycle
    
    convenience init(videoUrl: URL) {
        self.init(nibName: nil, bundle: nil)
        self.videoUrl = videoUrl
    }
    
    deinit {
		player.willMove(toParent: self)
        player.view.removeFromSuperview()
		player.removeFromParent()
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gNavigationViewController?.isNavigationBarHidden = false
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        player.playerDelegate = self
        player.playbackDelegate = self
        player.view.frame = view.bounds
        
		addChild(player)
        view.addSubview(player.view)
		player.didMove(toParent: self)
        
        view.insertSubview(timeRemainingLabel, aboveSubview: player.view)
        timeRemainingLabel.textColor = .white
        timeRemainingLabel.autoPinEdge(.left, to: .left, of: view, withOffset: 5)
        timeRemainingLabel.autoPinEdge(toSuperviewEdge: .bottom)
        timeRemainingLabel.autoSetDimensions(to: CGSize(width: 60, height: 30))
        
        view.insertSubview(playbackProgressView, aboveSubview: player.view)
        playbackProgressView.autoPinEdge(.left, to: .right, of: timeRemainingLabel, withOffset: 0)
        playbackProgressView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 5)
        playbackProgressView.autoPinEdge(toSuperviewEdge: .right)
        playbackProgressView.autoSetDimension(.height, toSize: 20)
        
        view.insertSubview(playbackImage, aboveSubview: player.view)
        playbackImage.autoSetDimensions(to: CGSize(width: 80, height: 80))
        playbackImage.autoCenterInSuperview()
        playbackImage.layer.cornerRadius = 40
        playbackImage.backgroundColor = .clear
        playbackImage.isHidden = true
        
        player.url = videoUrl
        player.fillMode = PlayerFillMode.resizeAspectFill
        player.playbackLoops = false
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        player.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gNavigationViewController?.isNavigationBarHidden = true
    }
    
    fileprivate func showPlaybackImage(image: UIImage) {
        playbackImage.image = image
        animatePlaybackImage()
    }
    
    fileprivate func animatePlaybackImage() {
		UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.playbackImage.isHidden = false
            self.playbackImage.alpha = 0.0
            self.playbackImage.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            
        }, completion: { _ in
            self.playbackImage.transform = CGAffineTransform.identity
            self.playbackImage.isHidden = true
            self.playbackImage.alpha = 1.0
        })
    }
}

// MARK: - UIGestureRecognizer extension
extension VideoPlayerViewController {
    
    @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        switch self.player.playbackState.rawValue {
        case PlaybackState.stopped.rawValue:
            showPlaybackImage(image: #imageLiteral(resourceName: "PlayVideo"))
            player.playFromBeginning()
        case PlaybackState.paused.rawValue:
            showPlaybackImage(image: #imageLiteral(resourceName: "PlayVideo"))
            player.playFromCurrentTime()
        case PlaybackState.playing.rawValue:
            showPlaybackImage(image: #imageLiteral(resourceName: "PauseVideo"))
            player.pause()
        case PlaybackState.failed.rawValue:
            showPlaybackImage(image: #imageLiteral(resourceName: "PauseVideo"))
            player.pause()
        default:
            showPlaybackImage(image: #imageLiteral(resourceName: "PauseVideo"))
            player.pause()
        }
    }
}

// MARK: - PlayerDelegate extension
extension VideoPlayerViewController: PlayerDelegate {
	func player(_ player: Player, didFailWithError error: Error?) {
		
	}
    
    func playerReady(_ player: Player) {
        player.playFromBeginning()
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
        
    }
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        
    }
}

// MARK: - PlayerPlaybackDelegate extension
extension VideoPlayerViewController: PlayerPlaybackDelegate {
    
    func playerCurrentTimeDidChange(_ player: Player) {
        let fraction = Double(player.currentTime) / Double(player.maximumDuration)
        playbackProgressView.setProgress(Float(fraction), animated: true)
        
        let timeRemaining: Float64 = player.maximumDuration - player.currentTime
        timeRemainingLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
        playbackProgressView.setProgress(0, animated: false)
        timeRemainingLabel.text = String(format: "%02d:%02d", ((lround(0) / 60) % 60), lround(player.maximumDuration) % 60)
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
        self.playbackProgressView.setProgress(1.0, animated: false)
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
        playbackProgressView.progress = 0
    }
}
