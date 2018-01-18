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
    
    fileprivate let currentProgress = Progress(totalUnitCount: Int64(imageArray.count))
    
    //MARK:- Class functions
    
    /**
     Save the video to the photo library.
     - parameter videoURL: The path of the timelapse video.
     */
    class func saveToLibrary(videoURL: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            }) { success, error in
                if !success {
                    ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.photoSaveError)
                }
            }
        }
    }
    
    /**
     Delete the video from the photo library.
     - parameter fileURL: The path of the timelapse video.
     */
    class func removeFileAtURL(fileURL: URL) {
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
        }
        catch _ as NSError {
            // Assume file doesn't exist.
        }
    }
    
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
        TimeLapseBuilder.removeFileAtURL(fileURL: settings.outputURL!)
        
        videoWriter.start()
        videoWriter.render(appendPixelBuffers: appendPixelBuffers) {
            progress(self.currentProgress)
            TimeLapseBuilder.saveToLibrary(videoURL: self.settings.outputURL!)
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
        
        while !imageArray.isEmpty {
            
            if writer.isReadyForData == false {
                // Inform writer we have more buffers to write.
                return false
            }
            let image = imageArray.removeFirst()
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
        
        var pixelBufferOut: CVPixelBuffer?
        
        let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pixelBufferOut)
        if status != kCVReturnSuccess {
            fatalError("CVPixelBufferPoolCreatePixelBuffer() failed")
        }
        
        let pixelBuffer = pixelBufferOut!
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let data = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: data, width: Int(size.width), height: Int(size.height),
                                bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        context!.clear(CGRect(x:0,y: 0,width: size.width,height: size.height))
        
        let horizontalRatio = size.width / image.size.width
        let verticalRatio = size.height / image.size.height
        let aspectRatio = max(horizontalRatio, verticalRatio) // ScaleAspectFill
        //let aspectRatio = min(horizontalRatio, verticalRatio) // ScaleAspectFit
        
        let newSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
        
        let x = newSize.width < size.width ? (size.width - newSize.width) / 2 : 0
        let y = newSize.height < size.height ? (size.height - newSize.height) / 2 : 0
        
        context?.draw(image.cgImage!, in: CGRect(x: x, y: y, width: newSize.width, height: newSize.height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
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
                kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: NSNumber(value: Float(renderSettings.size.width)),
                kCVPixelBufferHeightKey as String: NSNumber(value: Float(renderSettings.size.height))
            ]
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput,
                                                                      sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        }
        
        /// Create the asset writer.
        func createAssetWriter(outputURL: URL) -> AVAssetWriter {
            guard let assetWriter = try? AVAssetWriter(outputURL: outputURL, fileType: AVFileTypeMPEG4) else {
                fatalError("AVAssetWriter() failed")
            }
            
            guard assetWriter.canApply(outputSettings: avOutputSettings, forMediaType: AVMediaTypeVideo) else {
                fatalError("canApplyOutputSettings() failed")
            }
            
            return assetWriter
        }
        
        videoWriter = createAssetWriter(outputURL: renderSettings.outputURL!)
        videoWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: avOutputSettings)
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
