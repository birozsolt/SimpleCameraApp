//
//  RenderSettings.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 19/12/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import AVFoundation

///Define settings for the timelapse video
struct RenderSettings {
    
    ///Size of the output video
    var size : CGSize = CGSize(width: 1280, height: 720)
    
    ///Frame per second in the output video
    var fps: Int32 = 6
    
    ///Specifies the video encoding key.
    var avCodecKey = AVVideoCodecH264
    
    ///The file name as the video will be saved
    var videoFilename = LocalizedKeys.videoName.description()
    
    ///The file extension of saved video.
    var videoFilenameExt = LocalizedKeys.videoExt.description()
    
    ///The output URL where the video file will be saved
    var outputURL: URL? {
        // Use the CachesDirectory so the rendered video file sticks around as long as we need it to.
        // Using the CachesDirectory ensures the file won't be included in a backup of the app.
        let fileManager = FileManager.default
        if let tmpDirURL = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            return tmpDirURL.appendingPathComponent(videoFilename).appendingPathExtension(videoFilenameExt)
        } else {
            return nil
        }
    }
}
