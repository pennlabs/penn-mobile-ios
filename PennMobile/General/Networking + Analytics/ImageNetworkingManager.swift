//
//  ImageNetworkingManager.swift
//  PennMobile
//
//  Created by Josh Doman on 3/7/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//
import Foundation

class ImageNetworkingManager: NSObject, Requestable {
    static let instance = ImageNetworkingManager()
    
    private let cache = NSCache<NSString, UIImage>()
    
    func downloadImage(imageUrl: String, _ callback: @escaping (_ image: UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: imageUrl as NSString) {
            callback(cachedImage)
            return
        }
        
        guard let url = URL(string: imageUrl) else { return }
        let request = NSMutableURLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            var image: UIImage? = nil
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let data = data, let imageFromData = UIImage(data: data) {
                self.cache.setObject(imageFromData, forKey: imageUrl as NSString)
                image = imageFromData
            }
            callback(image)
        })
        task.resume()
    }
}

extension UIImageView {
    func loadImage(_ imageUrl: String) {
        ImageNetworkingManager.instance.downloadImage(imageUrl: imageUrl) { (image) in
            self.image = image
        }
    }
}
