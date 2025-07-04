//
//
//  Created by DREAMWORLD on 25/12/23.
//

import UIKit
import Photos

class PhotoAlbumManager {

    static func createAlbumIfNeeded(albumName: String, completion: @escaping (PHAssetCollection?) -> Void) {
        // Request authorization to access the photo library
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Permission not granted.")
                showAlertPermission(title: "Photo library Permission Denied!", message: "Please go to setting and enable Photo library permission.")
                completion(nil)
                return
            }
            
            // Fetch existing albums
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            let existingAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            // Check if the album already exists
            if let existingAlbum = existingAlbums.firstObject {
                print("Album already exists: \(albumName)")
                completion(existingAlbum)
            }
            else {
                // Create a new album
                var placeholder: PHObjectPlaceholder?
                PHPhotoLibrary.shared().performChanges({
                    let albumChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                    placeholder = albumChangeRequest.placeholderForCreatedAssetCollection
                })
                { success, error in
                    if success, let placeholder = placeholder {
                        // Fetch the newly created album
                        let newAlbum = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil).firstObject
                        print("Created new album: \(albumName)")
                        completion(newAlbum)
                    } else {
                        print("Error creating album: \(error?.localizedDescription ?? "Unknown error")")
                        completion(nil)
                    }
                }
            }
        }
    }

    
    static func saveImageToAlbum(image: UIImage, albumName: String) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Permission not granted.")
                showAlertPermission(title: "Photo library Permission Denied!", message: "Please go to setting and enable Photo library permission.")
                return
            }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            if let album = collection.firstObject {
                PHPhotoLibrary.shared().performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                    albumChangeRequest?.addAssets([assetPlaceholder!] as NSFastEnumeration)
                }, completionHandler: { success, error in
                    if success {
                        print("Image saved to album successfully")
                    } else if let error = error {
                        print("Error saving image to album: \(error)")
                    }
                })
            }
        }
    }
    
    static func saveImageUrlToAlbum(imageURL: URL, albumName: String, completion: @escaping (Bool, PHAsset?) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Permission not granted.")
                showAlertPermission(title: "Photo library Permission Denied!", message: "Please go to settings and enable Photo library permission.")
                completion(false, nil)
                return
            }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            if let album = collection.firstObject {
                var assetPlaceholder: PHObjectPlaceholder? // Declare a placeholder variable
                
                PHPhotoLibrary.shared().performChanges({
                    if let image = UIImage(contentsOfFile: imageURL.path) {
                        let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                        assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset // Capture the placeholder
                    }
                }, completionHandler: { success, error in
                    if success, let placeholder = assetPlaceholder {
                        print("Image saved to album successfully")
                        
                        // Now that we have the placeholder, add it to the album
                        PHPhotoLibrary.shared().performChanges({
                            let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                            albumChangeRequest?.addAssets([placeholder] as NSFastEnumeration)
                        }, completionHandler: { albumSuccess, albumError in
                            if albumSuccess {
                                // Fetch the saved asset using its local identifier
                                let savedAsset = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil).firstObject
                                completion(true, savedAsset) // Return the saved PHAsset
                            }
                            else {
                                print("Error adding asset to album: \(String(describing: albumError))")
                                completion(false, nil) // Return nil if there's an error
                            }
                        })
                    } else if let error = error {
                        print("Error saving image to album: \(error)")
                        completion(false, nil) // Return nil if there's an error
                    }
                })
            } else {
                print("Album not found.")
                completion(false, nil) // Return nil if the album isn't found
            }
        }
    }

    
//    static func saveImageUrlToAlbum(imageURL: URL, albumName: String, completion: @escaping (Bool) -> Void) {
//        PHPhotoLibrary.requestAuthorization { status in
//            guard status == .authorized else {
//                print("Permission not granted.")
//                showAlertPermission(title: "Photo library Permission Denied!", message: "Please go to setting and enable Photo library permission.")
//                completion(false)
//                return
//            }
//            let fetchOptions = PHFetchOptions()
//            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
//
//            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
//
//            if let album = collection.firstObject {
//                PHPhotoLibrary.shared().performChanges({
//                    if let image = UIImage(contentsOfFile: imageURL.path) {
//                        let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
//                        let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
//                        let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
//                        albumChangeRequest?.addAssets([assetPlaceholder!] as NSFastEnumeration)
//                    }
//                }, completionHandler: { success, error in
//                    if success {
//                        print("Image saved to album successfully")
//                        completion(true)
//                    } else if let error = error {
//                        print("Error saving image to album: \(error)")
//                        completion(false)
//                    }
//                })
//            }else{
//                completion(false)
//            }
//        }
//    }
    
    
    static func saveVideoToAlbum(videoURL: URL, albumName: String, completion: @escaping (Bool, PHAsset?) -> ()) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Permission not granted.")
                showAlertPermission(title: "Photo library Permission Denied!", message: "Please go to settings and enable Photo library permission.")
                completion(false, nil)
                return
            }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            if let album = collection.firstObject {
                // Declare a variable to hold the asset placeholder
                var assetPlaceholder: PHObjectPlaceholder?
                
                PHPhotoLibrary.shared().performChanges({
                    // Create the asset change request and capture the placeholder
                    let changeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                    assetPlaceholder = changeRequest?.placeholderForCreatedAsset // Capture the placeholder
                }, completionHandler: { success, error in
                    if success, let placeholder = assetPlaceholder {
                        print("Video saved to album successfully")
                        
                        // Now that we have the placeholder, add it to the album
                        PHPhotoLibrary.shared().performChanges({
                            let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                            albumChangeRequest?.addAssets([placeholder] as NSFastEnumeration)
                        }, completionHandler: { albumSuccess, albumError in
                            if albumSuccess {
                                // Fetch the saved asset using its local identifier
                                let savedAsset = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil).firstObject
                                completion(true, savedAsset) // Return the saved PHAsset
                            } else {
                                print("Error adding asset to album: \(String(describing: albumError))")
                                completion(false, nil) // Return nil if there's an error
                            }
                        })
                    } else if let error = error {
                        print("Error saving video to album: \(error)")
                        completion(false, nil) // Return nil if there's an error
                    }
                })
            } else {
                print("Album not found.")
                completion(false, nil) // Return nil if the album isn't found
            }
        }
    }


//    static func saveVideoToAlbum(videoURL: URL, albumName: String,completion:@escaping(Bool)->()) {
//        PHPhotoLibrary.requestAuthorization { status in
//            guard status == .authorized else {
//                print("Permission not granted.")
//                showAlertPermission(title: "Photo library Permission Denied!", message: "Please go to setting and enable Photo library permission.")
//                completion(false)
//                return
//            }
//            let fetchOptions = PHFetchOptions()
//            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
//
//            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
//
//            if let album = collection.firstObject {
//                PHPhotoLibrary.shared().performChanges({
//                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
//                    let assetPlaceholder = assetChangeRequest?.placeholderForCreatedAsset
//                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
//                    albumChangeRequest?.addAssets([assetPlaceholder!] as NSFastEnumeration)
//                }, completionHandler: { success, error in
//                    if success {
//                        print("Video saved to album successfully")
//                        completion(true)
//                    }
//                    else if let error = error {
//                        print("Error saving video to album: \(error)")
//                        completion(false)
//                    }
//                })
//            }else{
//                completion(false)
//            }
//        }
//    }
    
    static func getAlbum(named albumName: String, completion: @escaping ([PHAsset]?) -> ()) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                completion(nil)
                print("Permission not granted.")
                showAlertPermission(title: "Photo library Permission Denied!", message: "Please go to settings and enable Photo library permission.")
                return
            }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            guard let album = collection.firstObject else {
                completion(nil)
                print("Album not found.")
                return
            }
            
            // Fetch assets in the album
            let assetsFetchResult = PHAsset.fetchAssets(in: album, options: nil)
            var assets: [PHAsset] = []
            assetsFetchResult.enumerateObjects { asset, _, _ in
                assets.append(asset)
            }
            
            completion(assets)
        }
    }

    
//    static func getAlbum(named albumName: String,completion:@escaping(PHFetchResult<PHAsset>?)->()) {
//        PHPhotoLibrary.requestAuthorization { status in
//            guard status == .authorized else {
//                completion(nil)
//                print("Permission not granted.")
//                showAlertPermission(title: "Photo library Permission Denied!", message: "Please go to setting and enable Photo library permission.")
//                return
//            }
//            let fetchOptions = PHFetchOptions()
//            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
//            //        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//            
//            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
//            
//            var assets: PHFetchResult<PHAsset>?
//            let Option = PHFetchOptions()
//            assets = PHAsset.fetchAssets(in: collection.firstObject ?? PHAssetCollection(), options: Option)
//            completion(assets)
//        }
//    }
    
//    static func getSpecificAlbums(completion: @escaping ([PHAssetCollection]) -> ()) {
//        PHPhotoLibrary.requestAuthorization { status in
//            guard status == .authorized else {
//                completion([])
//                print("Permission not granted.")
//                showAlertPermission(title: "Photo library Permission Denied!", message: "Please go to setting and enable Photo library permission.")
//                return
//            }
//            var specificAlbums: [PHAssetCollection] = []
//            
//            let albumNames = [Constants.photosFolder, Constants.videoFolder]
//            
//            let fetchOptions = PHFetchOptions()
//            fetchOptions.predicate = NSPredicate(format: "title IN %@", albumNames)
//            
//            // Fetch user albums with specific names
//            let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
//            userAlbums.enumerateObjects { (collection, _, _) in
//                specificAlbums.append(collection)
//            }
//            completion(specificAlbums)
//        }
//    }
    
    static func deleteAsset(asset: PHAsset, completion: @escaping (Bool, Error?) -> ()) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("Asset deleted successfully")
                } else if let error = error {
                    print("Error deleting asset: \(error)")
                }
                completion(success, error)
            }
        }
    }
    
    static func showAlertPermission(title : String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let settingAction = UIAlertAction(title: "Setting", style: .default, handler: { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
               return
            }
            DispatchQueue.main.async {
                if UIApplication.shared.canOpenURL(url) {
                   UIApplication.shared.open(url, options: [:])
                }
            }
        })
        alertController.addAction(okAction)
        alertController.addAction(settingAction)
        DispatchQueue.main.async {
            ROOTVIEW?.present(alertController, animated: true, completion: nil)
        }
    }
}
