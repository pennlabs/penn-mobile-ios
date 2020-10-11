//
//  GSRNotificationService+ImageCacheing.swift
//  GSRNotificationServiceExtension
//
//  Created by Dominic Holmes on 3/5/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UserNotifications

extension UNNotificationRequest {
    func getImageAttachment(with urlString: String) -> UNNotificationAttachment? {
        guard let attachmentURL = URL(string: urlString), let imageData = try? Data(contentsOf: attachmentURL) else {
            return nil
        }
        return try? UNNotificationAttachment(data: imageData, options: nil)
    }
}

extension UNNotificationAttachment {
    convenience init(data: Data, options: [NSObject: AnyObject]?) throws {
        let fileManager = FileManager.default
        let temporaryFolderName = ProcessInfo.processInfo.globallyUniqueString
        let temporaryFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(temporaryFolderName, isDirectory: true)

        try fileManager.createDirectory(at: temporaryFolderURL, withIntermediateDirectories: true, attributes: nil)
        let imageFileIdentifier = UUID().uuidString + ".jpg"
        let fileURL = temporaryFolderURL.appendingPathComponent(imageFileIdentifier)
        try data.write(to: fileURL)
        try self.init(identifier: imageFileIdentifier, url: fileURL, options: options)
    }
}
