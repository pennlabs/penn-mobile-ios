//
//  SubletDraft.swift
//  PennMobile
//
//  Created by Anthony Li on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import UIKit

@dynamicMemberLookup
public struct SubletDraft: Identifiable, Codable, Hashable {
    public let id: UUID
    public var data: SubletData
    public var images: [UIImage]
    public var compressedImages = [UIImage: Data]()

    public subscript<T>(dynamicMember keyPath: KeyPath<SubletData, T>) -> T {
        data[keyPath: keyPath]
    }

    public init(id: UUID = UUID(), data: SubletData, images: [UIImage], compressedImages: [UIImage: Data] = [:]) {
        self.id = id
        self.data = data
        self.images = images
        self.compressedImages = compressedImages
    }

    public init(from decoder: Decoder) throws {
        let data = try SubletData(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let imageData = try container.decode([Data].self, forKey: .images)
        
        var images = [UIImage]()
        var compressedImages = [UIImage: Data]()
        for imageDatum in imageData {
            if let image = UIImage(data: imageDatum) {
                images.append(image)
                compressedImages[image] = imageDatum
            }
        }
        
        self.init(id: id, data: data, images: images, compressedImages: compressedImages)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try data.encode(to: encoder)
        let imageData = images.compactMap { compressedImages[$0] ?? $0.jpegData(compressionQuality: 0.5) }
        try container.encode(imageData, forKey: .images)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case images
    }
    
    public static func ==(lhs: SubletDraft, rhs: SubletDraft) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
