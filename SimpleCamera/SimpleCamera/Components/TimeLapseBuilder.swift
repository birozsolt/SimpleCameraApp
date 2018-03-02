//
//  TimeLapseBuilder.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 28/11/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

import AVFoundation
import UIKit
import Photos

class TimeLapseBuilder {
    
    // Apple suggests a timescale of 600 because it's a multiple of standard video rates 24, 25, 30, 60 fps etc.
    fileprivate static let kTimescale: Int32 = 600
    
    fileprivate let settings: RenderSettings
    fileprivate let videoWriter: VideoWriter
    
    fileprivate var frameNum = 0
    
    fileprivate let currentProgress = Progress(totalUnitCount: Int64(PhotoAlbum.sharedInstance.imageArray.count))
    
    //MARK: - Object Lifecycle
    
    /**
     Initialise the videoWriter
     - parameter renderSettings: The settings used for writing a video.
     */
    init(renderSettings: RenderSettings) {
        settings = renderSettings
        videoWriter = VideoWriter(renderSettings: settings)
    }
    
    /**
     Start writing the video and save it to Library after finished.
     - parameter progress: The progress of the writing process.
     - parameter completition: Completition handler after the writing process finished.
     */
    func render(_ progress: @escaping ((Progress) -> Void), completion: (()->Void)?) {
        // The VideoWriter will fail if a file exists at the URL, so clear it out first.
        PhotoAlbum.sharedInstance.removeFileAtURL(fileURL: settings.outputURL!)
        videoWriter.start()
        videoWriter.render(appendPixelBuffers: appendPixelBuffers) {
            progress(self.currentProgress)
            PhotoAlbum.sharedInstance.saveVideo(videoURL: self.settings.outputURL!)
            completion?()
        }
    }
    
    /**
     This is the callback function for VideoWriter.render().
     - parameter writer: The *AVAssetWriter* object to write media data to a new file.
     - returns: *False* if there is more image to write. *True* if all image added to the video.
     */
    fileprivate func appendPixelBuffers(writer: VideoWriter) -> Bool {
        let frameDuration = CMTimeMake(Int64(TimeLapseBuilder.kTimescale / settings.fps), TimeLapseBuilder.kTimescale)
        while !PhotoAlbum.sharedInstance.imageArray.isEmpty {
            
            if writer.isReadyForData == false {
                // Inform writer we have more buffers to write.
                return false
            }
            let image = PhotoAlbum.sharedInstance.imageArray.removeFirst()
            let presentationTime = CMTimeMultiply(frameDuration, Int32(frameNum))
            let success = videoWriter.addImage(image: image, withPresentationTime: presentationTime)
            if success == false {
                fatalError("addImage() failed")
            }
            currentProgress.completedUnitCount = Int64(frameNum)
            frameNum += 1
        }
        // Inform writer all buffers have been written.
        return true
    }
}

/// The videoWriter class, which implements the writing methodes.
private class VideoWriter {
    
    fileprivate let renderSettings: RenderSettings
    
    fileprivate var videoWriter: AVAssetWriter!
    fileprivate var videoWriterInput: AVAssetWriterInput!
    fileprivate var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    
    fileprivate var isReadyForData: Bool {
        return videoWriterInput?.isReadyForMoreMediaData ?? false
    }
    
    //MARK: - Class functions
    
    fileprivate class func pixelBufferFromImage(image: UIImage, pixelBufferPool: CVPixelBufferPool, size: CGSize) -> CVPixelBuffer {
        var ciimage = CIImage(image: image)
        //print(PhotoAlbum.sharedInstance.imageArray.averageRoll)
        guard let motionData = image.motionData else {
            fatalError()
        }
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -500.0
        transform = CATransform3DRotate(transform, motionData.roll.distance(to: PhotoAlbum.sharedInstance.imageArray.averageRoll).toRadians, 1, 0, 0)
        ciimage = ciimage?.transformed(by: CATransform3DGetAffineTransform(transform))
        print(PhotoAlbum.sharedInstance.imageArray.averageRoll, motionData.roll.distance(to: PhotoAlbum.sharedInstance.imageArray.averageRoll))
        
        transform = CATransform3DIdentity
        transform.m34 = 1.0 / -500.0
        transform = CATransform3DRotate(transform, motionData.roll.distance(to: PhotoAlbum.sharedInstance.imageArray.averagePitch).toRadians, 0, 1, 0)
        ciimage = ciimage?.transformed(by: CATransform3DGetAffineTransform(transform))

        transform = CATransform3DIdentity
        transform.m34 = 1.0 / -500.0
        transform = CATransform3DRotate(transform, motionData.roll.distance(to: PhotoAlbum.sharedInstance.imageArray.averageYaw).toRadians, 0, 0, 1)
        ciimage = ciimage?.transformed(by: CATransform3DGetAffineTransform(transform))
        
        let width: Int = Int(size.width)
        let height: Int = Int(size.height)
        
        var pxbuffer: CVPixelBuffer?
        // if pxbuffer = nil, you will get status = -6661
        let status =  CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pxbuffer)
        if status != kCVReturnSuccess {
            fatalError("CVPixelBufferPoolCreatePixelBuffer() failed")
        }
        CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        let bufferAddress = CVPixelBufferGetBaseAddress(pxbuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesperrow = CVPixelBufferGetBytesPerRow(pxbuffer!)
        let context = CGContext(data: bufferAddress,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesperrow,
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        context?.clear(CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)))
        let tmpcontext = CIContext(options: nil)
        
        let cgimage =  tmpcontext.createCGImage(ciimage!, from: ciimage!.extent)
        context?.concatenate(CGAffineTransform(rotationAngle: 0))
        context?.draw(cgimage!, in: CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)))
        CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pxbuffer!
    }
    
    //MARK:- Object Lifecycle
    
    init(renderSettings: RenderSettings) {
        self.renderSettings = renderSettings
    }
    
    /// Set up and start the asset writing.
    fileprivate func start() {
        
        /// The ouput settings for the assetWriter.
        let avOutputSettings: [String: Any] = [
            AVVideoCodecKey: renderSettings.avCodecKey,
            AVVideoWidthKey: NSNumber(value: Float(renderSettings.size.width)),
            AVVideoHeightKey: NSNumber(value: Float(renderSettings.size.height))
        ]
        
        /// Create the pixel buffer adaptor.
        func createPixelBufferAdaptor() {
            let sourcePixelBufferAttributesDictionary = [
                kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA),
                kCVPixelBufferWidthKey as String: NSNumber(value: Float(renderSettings.size.width)),
                kCVPixelBufferHeightKey as String: NSNumber(value: Float(renderSettings.size.height))
            ]
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput,
                                                                      sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        }
        
        /// Create the asset writer.
        func createAssetWriter(outputURL: URL) -> AVAssetWriter {
            guard let assetWriter = try? AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mp4) else {
                fatalError("AVAssetWriter() failed")
            }
            
            guard assetWriter.canApply(outputSettings: avOutputSettings, forMediaType: AVMediaType.video) else {
                fatalError("canApplyOutputSettings() failed")
            }
            return assetWriter
        }
        
        videoWriter = createAssetWriter(outputURL: renderSettings.outputURL!)
        videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: avOutputSettings)
        videoWriterInput.transform = CGAffineTransform(rotationAngle: CGFloat(90).toRadians)
        if videoWriter.canAdd(videoWriterInput) {
            videoWriter.add(videoWriterInput)
        }
        else {
            fatalError("canAddInput() returned false")
        }
        
        // The pixel buffer adaptor must be created before we start writing.
        createPixelBufferAdaptor()
        
        if videoWriter.startWriting() == false {
            fatalError("startWriting() failed")
        }
        
        videoWriter.startSession(atSourceTime: kCMTimeZero)
        
        precondition(pixelBufferAdaptor.pixelBufferPool != nil, "nil pixelBufferPool")
    }
    
    ///Render the video and finish writing.
    fileprivate func render(appendPixelBuffers: ((VideoWriter)->Bool)?, completion: (()->Void)?) {
        
        precondition(videoWriter != nil, "Call start() to initialze the writer")
        
        let queue = DispatchQueue(label: "mediaInputQueue")
        videoWriterInput.requestMediaDataWhenReady(on: queue) {
            let isFinished = appendPixelBuffers?(self) ?? false
            if isFinished {
                self.videoWriterInput.markAsFinished()
                self.videoWriter.finishWriting() {
                    DispatchQueue.main.async {
                        completion?()
                    }
                }
            }
            else {
                // Fall through. The closure will be called again when the writer is ready.
            }
        }
    }
    
    /**
     Add an image to a single *AVAssetWriterInputPixelBufferAdaptor* object.
     - parameter image: The image what will be used for the pixel buffer.
     - parameter presentationTime: The presentation time for the pixel buffer to be appended.
     - returns: *true* if the pixel buffer was successfully appended, otherwise *false*.
     */
    fileprivate func addImage(image: UIImage, withPresentationTime presentationTime: CMTime) -> Bool {
        
        precondition(pixelBufferAdaptor != nil, "Call start() to initialze the writer")
        
        let pixelBuffer = VideoWriter.pixelBufferFromImage(image: image, pixelBufferPool: pixelBufferAdaptor.pixelBufferPool!, size: renderSettings.size)
        return pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
    }
}
