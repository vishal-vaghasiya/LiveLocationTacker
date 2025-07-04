//
//  File.swift
//
//  Created by DREAMWORLD on 18/01/24.
//

import Foundation
import UIKit
import Photos

class FileUtility {

    static let shared = FileUtility()
        
    //MARK: - create folder -
    
    func createFolder(folderName: String,completion:@escaping(String)->()) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderURL = documentsDirectory.appendingPathComponent(folderName)

        do {
            // Check if the folder already exists
            if !fileManager.fileExists(atPath: folderURL.path) {
                // Create the folder
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                print("Folder created successfully: \(folderURL.path)")
                completion(folderURL.absoluteString)
            }
            else {
                print("Folder already exists: \(folderURL.path)")
                completion("")
            }
        } 
        catch {
            print("Error creating folder: \(error.localizedDescription)")
            completion("")
        }
    }
    
    func renameFolder(folderName: String, newName: String, completion: @escaping (Error?) -> Void) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderURL = documentsDirectory.appendingPathComponent(folderName)
        let newFolderURL = folderURL.deletingLastPathComponent().appendingPathComponent(newName)

        // Perform the renaming operation asynchronously
        DispatchQueue.global().async {
            do {
                // Rename the folder
                try fileManager.moveItem(at: folderURL, to: newFolderURL)
                DispatchQueue.main.async {
                    // Call the completion handler with nil to indicate success
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    // Call the completion handler with the error if an error occurs
                    completion(error)
                }
            }
        }
    }
    
    func deleteAlbum(named albumName: String, completion: @escaping (Error?) -> Void) {
        let fileManager = FileManager.default
        let homeDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let albumURL = homeDirectory.appendingPathComponent(albumName)
        
        do {
            try fileManager.removeItem(at: albumURL)
            print("Album '\(albumName)' deleted successfully.")
            completion(nil)
        } catch {
            print("Error deleting album '\(albumName)': \(error.localizedDescription)")
            completion(error)
        }
    }
    
    func getAllAlbums() -> [String]? {
        let fileManager = FileManager.default
        let homeDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var albums: [String] = []

        do {
            // Get the contents of the home directory
            let contents = try fileManager.contentsOfDirectory(at: homeDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

            // Filter out directories and extract their names
            for item in contents {
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: item.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                    let albumName = item.lastPathComponent
                    if albumName != "Recently Delete" {
                        albums.append(albumName)
                    }
                }
            }
            // Ensure "Main Albums" is at the first index
            if let mainAlbumsIndex = albums.firstIndex(of: "Main Albums") {
                albums.remove(at: mainAlbumsIndex)
                albums.insert("Main Albums", at: 0)
            }
            
            return albums
        } 
        catch {
            print("Error while getting contents of directory: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Image Functions -
    
    func saveImageToDocumentDirectory(image: UIImage, fileName: String, completion: @escaping (URL?) -> Void) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(nil)
            return
        }
        let seconds: TimeInterval = Date().timeIntervalSince1970
        let fileURL = documentsDirectory.appendingPathComponent("\(fileName)/\(seconds).png")
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            do {
                try imageData.write(to: fileURL)
                completion(fileURL)
            }
            catch {
                print("Error saving image: \(error.localizedDescription)")
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
    
    // MARK: - Music Functions -
    
    func saveMusicToDocumentDirectory(musicData: Data, fileName: String, fileExtension: String, completion: @escaping (URL?) -> Void) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(nil)
            return
        }
        
        let timestamp = Date().timeIntervalSince1970
        let fileURL = documentsDirectory.appendingPathComponent("\(fileName)_\(timestamp).\(fileExtension)")
        
        do {
            try musicData.write(to: fileURL)
            completion(fileURL)
        } catch {
            print("Error saving music file: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    
    // MARK: - Video Functions -
    
    func saveVideoToDocuments(videoAsset: PHAsset, fileName: String, completion: @escaping (URL?) -> Void) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestAVAsset(forVideo: videoAsset, options: options) { (avAsset, _, _) in
            guard let avAsset = avAsset as? AVURLAsset else {
                completion(nil)
                return
            }
            
            let videoURL = avAsset.url
            
            do {
                let seconds: TimeInterval = Date().timeIntervalSince1970
                let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let destinationURL = documentsURL.appendingPathComponent("\(fileName)/\(seconds).mp4") // Use the provided filename with mp4 extension
                    
                try FileManager.default.copyItem(at: videoURL, to: destinationURL)
                completion(destinationURL)
            }
            catch {
                print("Error saving video: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func fetchMediaFromFolder(folderName: String) -> [URL]? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let folderURL = documentsDirectory.appendingPathComponent(folderName)
        
        do {
            // Get the contents of the directory
            let contents = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            // Filter out media files
            let mediaFiles = contents.filter { url -> Bool in
                let fileExtension = url.pathExtension.lowercased()
                return fileExtension == "jpg" || fileExtension == "jpeg" || fileExtension == "png" || fileExtension == "mov" || fileExtension == "mp4"
            }
            
            return mediaFiles
        } catch {
            print("Error while getting contents of directory: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteFile(at fileURL: URL, completion: @escaping (Error?) -> Void) {
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: fileURL)
            print("File deleted successfully.")
            completion(nil)
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
            completion(error)
        }
    }
    
    func saveFileToCustomFolder(fileURL: URL, folderName: String,completionHandler: @escaping(URL?)->()) {
        let fileManager = FileManager.default
        
        // Get the documents directory URL
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not access the documents directory.")
            completionHandler(nil)
            return
        }
        
        // Create a URL for the custom folder
        let customFolderURL = documentsURL.appendingPathComponent(folderName, isDirectory: true)
        
        // Move the file to the custom folder
        let destinationURL = customFolderURL.appendingPathComponent(fileURL.lastPathComponent)
        do {
            try fileManager.moveItem(at: fileURL, to: destinationURL)
            print("File moved to custom folder: \(destinationURL.path)")
            
            completionHandler(destinationURL)
        } 
        catch {
            completionHandler(nil)
            print("Error: Failed to move file to custom folder: \(error.localizedDescription)")
        }
    }
}
