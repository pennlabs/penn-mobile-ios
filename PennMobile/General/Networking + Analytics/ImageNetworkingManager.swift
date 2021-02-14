//
//  ImageNetworkingManager.swift
//  PennMobile
//
//  Created by Josh Doman on 3/7/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//
import Foundation
import Kingfisher

class ImageNetworkingManager {
    static let instance = ImageNetworkingManager()
    private init() {}
    
    func downloadImage(imageUrl: String, _ callback: @escaping (_ image: UIImage?) -> Void) {
        ImageCache.default.retrieveImage(forKey: imageUrl) { (result) in
            if let imageCacheResult = try? result.get(),
                let image = imageCacheResult.image {
                callback(image)
            } else {
                guard let url = URL(string: imageUrl) else { return }
                ImageDownloader.default.downloadImage(with: url, options: [], progressBlock: nil) { (result) in
                    if let imageResult = try? result.get() {
                        ImageCache.default.store(imageResult.image, forKey: imageUrl)
                        callback(imageResult.image)
                    } else {
                        callback(nil)
                    }
                }
            }
        }
    }

}
