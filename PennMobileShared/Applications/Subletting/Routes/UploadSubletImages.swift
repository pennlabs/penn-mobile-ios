//
//  UploadSubletImages.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import UIKit

public extension PennMobileApplication.Subletting {
    struct UploadSubletImages: PennMobileEndpoint {
        public typealias Response = [SubletImage]
        public let path: String
        public let method = "POST"
        public let authenticated = true
        public let headers: [String: String]?
        public let bodyData: Data?
        public let responseDecoder: JSONDecoder? = .snakeCaseFlexibleDates

        public init(subletId: Int, images: [UIImage]) throws {
            let body = try MultipartBody {
                try MultipartContent(name: "sublet", content: "\(subletId)")
                
                for (index, image) in images.enumerated() {
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        MultipartContent(type: "image/jpeg", name: "images", filename: "image\(index).jpeg", data: imageData)
                    }
                }
            }
            
            self.path = "/sublet/properties/\(subletId)/images/"
            self.headers = ["Content-Type": body.contentType]
            self.bodyData = try body.assembleData()
        }
    }
}
