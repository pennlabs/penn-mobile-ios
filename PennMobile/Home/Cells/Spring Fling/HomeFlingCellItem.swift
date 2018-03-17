//
//  HomeFlingCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/9/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeFlingCellItem: HomeCellItem {
    
    static var jsonKey: String {
        return "fling"
    }
    
    let performer: FlingPerformer
    var image: UIImage?
    
    init(performer: FlingPerformer) {
        self.performer = performer
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        guard let json = json else { return nil }
        return try? HomeFlingCellItem(json: json)
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeFlingCell.self
    }
    
    func equals(item: HomeCellItem) -> Bool {
        guard let item = item as? HomeFlingCellItem else { return false }
        return performer.name == item.performer.name
    }
}

// MARK: - HomeAPIRequestable
extension HomeFlingCellItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        ImageNetworkingManager.instance.downloadImage(imageUrl: performer.imageUrl) { (image) in
            self.image = image
            completion()
        }
    }
}

// MARK: - JSON Parsing
extension HomeFlingCellItem {
    convenience init(json: JSON) throws {
        guard let name = json["name"].string,
            let description = json["description"].string,
            let imageUrl = json["image_url"].string,
            let startTimeStr = json["start_time"].string,
            let endTimeStr = json["end_time"].string else {
                throw NetworkingError.jsonError
        }
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        
        guard let startTime = formatter.date(from: startTimeStr), let endTime = formatter.date(from: endTimeStr) else {
            throw NetworkingError.jsonError
        }
        
        let performer = FlingPerformer(name: name, imageUrl: imageUrl, description: description, startTime: startTime, endTime: endTime)
        self.init(performer: performer)
    }
}
