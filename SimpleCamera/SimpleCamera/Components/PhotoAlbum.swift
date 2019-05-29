//
//  PhotoAlbum.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 12/02/2018.
//  Copyright © 2018 Biro, Zsolt. All rights reserved.
//

import Photos

class PhotoAlbum: NSObject {
    static let albumName = LocalizedKeys.photoAlbumName.localized
    static let sharedInstance = PhotoAlbum()
    var imageArray = [UIImage]()
    
    private var assetCollection: PHAssetCollection!
    
    fileprivate override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ _ -> Void in
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
			// create an asset collection with the album name
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoAlbum.albumName)
        }, completionHandler: { success, _ in
            if success {
                self.assetCollection = self.fetchAssetCollectionForAlbum()
            } else {
                ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.albumCreateError)
            }
        })
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
        }, completionHandler: { success, _ in
            if !success {
                ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.photoSaveError)
            }
        })
    }
    
    /**
     Delete the video from the photo library.
     - parameter fileURL: The path of the timelapse video.
     */
    func removeFileAtURL(fileURL: URL) {
        PHPhotoLibrary.shared().performChanges({
            let options = PHFetchOptions()
            let imageToDelete = PHAsset.fetchAssets(with: options) //PHAsset.fetchAssets(withALAssetURLs: [fileURL], options: nil)
            PHAssetChangeRequest.deleteAssets(imageToDelete)
        }, completionHandler: {success, _ in
            if !success {
                ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.albumCreateError)
            }
        })
    }
    
    func getPhotoFromAlbum() {
        if assetCollection == nil {
            print("Asset collection not found.") // if there was an error upstream, skip the save
        }
        
        let photoAssets = PHAsset.fetchAssets(in: assetCollection, options: nil)
        let manager = PHCachingImageManager()
        photoAssets.enumerateObjects { (object, _, _) -> Void in
                let asset = object
                
                let initialRequestOptions = PHImageRequestOptions()
                initialRequestOptions.isSynchronous = true
                initialRequestOptions.deliveryMode = .fastFormat
                
                manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize,
									 contentMode: .default, options: initialRequestOptions,
									 resultHandler: { (image, _) in
                    if let unWrappedImage = image {
                        self.imageArray.append(unWrappedImage)
                    }
                    PHPhotoLibrary.shared().performChanges({
						guard let asset = asset as? NSFastEnumeration else {
							return
						}
                        PHAssetChangeRequest.deleteAssets(asset)
                    }, completionHandler: {success, _ in
                        if !success {
                            ErrorMessage.sharedInstance.show(LocalizedKeys.titleError, message: LocalizedKeys.albumCreateError)
                        }
                    })
                })
        }
        print(photoAssets.count)
    }
    
    func getPhotoAlbumSize() -> Int {
        let assets = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
        return assets.count
    }
}
