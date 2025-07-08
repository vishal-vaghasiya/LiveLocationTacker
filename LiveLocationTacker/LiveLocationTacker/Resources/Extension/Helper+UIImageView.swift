//
//  Helper+UIImageView.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 08/07/25.
//

import Foundation
import Photos
import SDWebImage

extension UIImageView {
    // MARK: - Universal Image Setter
    func setImage(
        urlString: String,
        name: String? = nil,
        placeholderImage: UIImage? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        textColor: UIColor = .black,
        backgroundColor: UIColor = .white
    ) {
        var encodedURLString = urlString
        encodedURLString = encodedURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let imageURL = URL(string: encodedURLString) else {
            if let name = name, let width = width, let height = height {
                setPlaceholderImage(name: name, width: width, height: height)
            } else {
                self.image = placeholderImage
            }
            return
        }
        
        let cacheKey = SDWebImageManager.shared.cacheKey(for: imageURL)
        if let cachedImage = SDImageCache.shared.imageFromCache(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        self.sd_setImage(with: imageURL, placeholderImage: placeholderImage, options: [.avoidAutoSetImage, .highPriority]) { (img, error, cacheType, url) in
            if let img = img {
                self.image = img
            } else {
                if let name = name, let width = width, let height = height {
                    self.setPlaceholderImage(name: name, width: width, height: height)
                } else {
                    self.image = placeholderImage
                }
            }
        }
    }
    
    // MARK: - Placeholder Image Generator
    // Helper function to set placeholder with initials
    private func setPlaceholderImage(name: String?, width: CGFloat, height: CGFloat) {
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = .darkGray
        nameLabel.textColor = .white
        nameLabel.font = FontFamily.Poppins.bold.font(size: width / 2.5)
        nameLabel.text = getNamePrefix(from: name ?? "O")

        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            nameLabel.layer.render(in: currentContext)
            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.image = nameImage
        }
    }
    
}

func getNamePrefix(from name: String, isMiddleWordShown: Bool = false) -> String{
    if name != ""{
        let split = name.split(separator: " ")
        if split.count == 2 {
            let name1 = split[0].prefix(1).uppercased()
            let name2 = split[1].prefix(1).uppercased()
            return name1 + name2
        } else if split.count >= 3 {
            let name1 = split[0].prefix(1).uppercased()
            let name2 = split[isMiddleWordShown ? 1 : 2].prefix(1).uppercased()
            return name1 + name2
        } else {
            return name.prefix(name.count > 1 ? (isMiddleWordShown ? 2 : 1) : 1).uppercased()
        }
    } else {
        return "O"
    }
}
