//
//  GSRNotificationExtension.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/14/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit
import UserNotifications

/*
class NotificationService: UNNotificationServiceExtension {
    
    // IMPORTANT: To take advantage of this extension, set the 'mutable-content' flag to '1'
    /*
     Use this to test: https://github.com/onmyway133/PushNotifications
     Dominic's Device TokenId: EBA612F860AA80504F263BEBDBB1DC01DDE14C4B7D45E88ADA6BE300CD9D1BD2
     EXAMPLE NOTIFICATION PAYLOAD:
     {
         "aps": {
             "alert": {
                 "body": "This is the body text, concerning your GSR in WIC RM 123 from 9:30-11am.",
                 "title": "Upcoming GSR",
                 "subtitle": "WIC Rm 129",
                 "other info, like booking ids": "etc"
             },
             "mutable-content": 1,
             "thread-id": 1,
             "category": "UPCOMING_GSR"
         },
         "media-url": "https://s3.us-east-2.amazonaws.com/labs.api/gsr/lid-1086-gid-1889.jpg",
         "sound": "default"
     }
     */
    

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        dump(bestAttemptContent)
        if let mutableContent = self.bestAttemptContent, let urlString = mutableContent.userInfo["media-url"] as? String, let url = URL(string: urlString) {
            
            dump(urlString)
            dump(mutableContent.userInfo)
            
            downloadImage(from: url) { (image) in
                print("DOWNLOADED IMAGE")
                guard let image = image, let mediaAttachment = UNNotificationAttachment.create(identifier: "photo", image: image, options: [:]) else {
                    contentHandler(mutableContent); return
                }
                mutableContent.attachments = [mediaAttachment]
                contentHandler(mutableContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        print("SERVICE EXTENSION EXPIRING")
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    // TODO: Replace this with Alamofire/Kingfisher methods that utilize image cacheing. Or don't.
    // From SO: https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> ()) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else {
                print("ERROR Downloading Image: \(error?.localizedDescription ?? "[]")")
                return
            }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            completion(UIImage(data: data))
        }
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}

extension UNNotificationAttachment {
    
    // Given an image, temporarily store it in the filesystem. Use the url of the file to create a UNNotificationAttachment. Caution: when the attachment is created, the image may be deleted from the file system (this is undocumented behavior)
    // Adapted from https://stackoverflow.com/questions/39103095/unnotificationattachment-with-uiimage-or-remote-url
    
    static func create(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier + ".png"
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            guard let imageData = image.pngData() else {
                return nil
            }
            try imageData.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment
        } catch {
            print("ERROR: " + error.localizedDescription)
        }
        return nil
    }
}

*/
