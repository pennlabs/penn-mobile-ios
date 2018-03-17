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
        ImageCache.default.retrieveImage(forKey: imageUrl, options: nil) { (image, cacheType) in
            if let image = image {
                callback(image)
            } else {
                guard let url = URL(string: imageUrl) else { return }
                ImageDownloader.default.downloadImage(with: url, options: [], progressBlock: nil) {
                    (image, error, url, data) in
                    if let image = image {
                        ImageCache.default.store(image, forKey: imageUrl)
                    }
                    callback(image)
                }
            }
        }
    }
}
