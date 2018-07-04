//
//  PhotoAlbum.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 12/02/2018.
//  Copyright © 2018 Biro, Zsolt. All rights reserved.
//

import Photos

class PhotoAlbum: NSObject {
    static let albumName = LocalizedKeys.photoAlbumName.description()
    static let sharedInstance = PhotoAlbum()
    var imageArray = Array<UIImage>()
    
    private var assetCollection: PHAssetCollection!
    
    fileprivate override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                ()
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            self.createAlbum()
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    private func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            // ideally this ensures the creation of the photo album even if authorization wasn't prompted till after init was done
            print("trying again to create the album")
            self.createAlbum()
        } else {
            print("should really prompt the user to let them know it's failed")
        }
    }
    
    private func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoAlbum.albumName)   // create an asset collection with the album name
        }) { success, error in
            if success {
                self.assetCollection = self.fetchAssetCollectionForAlbum()
            } else {
                ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.albumCreateError)
            }
        }
    }
    
    private func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", PhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject!
        }
        
        return nil
    }
    
    /**
     Save the image to the photo library.
     - parameter image: The image that will be saved.
     */
    func saveImage(image: UIImage) {
        if assetCollection == nil {
            return                          // if there was an error upstream, skip the save
        }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest!.addAssets(enumeration)
            
        }, completionHandler: nil)
    }
    
    /**
     Save the video to the photo library.
     - parameter videoURL: The path of the timelapse video.
     */
    func saveVideo(videoURL: URL) {
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            let assetPlaceHolder = assetChangeRequest?.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest!.addAssets(enumeration)
        }) { success, error in
            if !success {
                ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.photoSaveError)
            }
        }
    }
    
    /**
     Delete the video from the photo library.
     - parameter fileURL: The path of the timelapse video.
     */
    func removeFileAtURL(fileURL: URL) {
        PHPhotoLibrary.shared().performChanges({
            let imageToDelete = PHAsset.fetchAssets(withALAssetURLs: [fileURL], options: nil)
            PHAssetChangeRequest.deleteAssets(imageToDelete)
        }, completionHandler: {success, error in
            if !success {
                ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.albumCreateError)
            }
        })
    }
    
    func getPhotoFromAlbum(){
        if assetCollection == nil {
            print("Asset collection not found.") // if there was an error upstream, skip the save
        }
        
        let photoAssets = PHAsset.fetchAssets(in: assetCollection, options: nil)
        let manager = PHCachingImageManager()
        photoAssets.enumerateObjects { (object, idx, stop) -> Void in
            if object is PHAsset {
                let asset = object
                
                let initialRequestOptions = PHImageRequestOptions()
                initialRequestOptions.isSynchronous = true
                initialRequestOptions.deliveryMode = .fastFormat
                
                manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: initialRequestOptions, resultHandler: { (image, info) in
                    if let unWrappedImage = image {
                        self.imageArray.append(unWrappedImage)
                    }
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.deleteAssets(asset as! NSFastEnumeration)
                    }, completionHandler: {success, error in
                        if !success {
                            ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.albumCreateError)
                        }
                    })
                })
            }
        }
        print(photoAssets.count)
    }
    
    func getPhotoAlbumSize() -> Int {
        let assets = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
        return assets.count
    }
}
