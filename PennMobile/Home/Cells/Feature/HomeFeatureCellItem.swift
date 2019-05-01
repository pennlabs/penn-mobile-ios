//
//  HomeFeatureCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

final class HomeFeatureCellItem: HomeCellItem {
    
    static var jsonKey: String {
        return "feature"
    }
    
    let announcement: FeatureAnnouncement
    var image: UIImage?
    var showSubtitle = false
    
    init(announcement: FeatureAnnouncement) {
        self.announcement = announcement
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        guard let json = json else { return nil }
        return try? HomeFeatureCellItem(json: json)
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeFeatureCell.self
    }
    
    func equals(item: HomeCellItem) -> Bool {
        guard let item = item as? HomeFeatureCellItem else { return false }
        return announcement.title == item.announcement.title
    }
}

// MARK: - HomeAPIRequestable
extension HomeFeatureCellItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        ImageNetworkingManager.instance.downloadImage(imageUrl: announcement.imageUrl) { (image) in
            self.image = image
            completion()
        }
    }
}

// MARK: - JSON Parsing
extension HomeFeatureCellItem {
    convenience init(json: JSON) throws {
        let announcement = try FeatureAnnouncement(json: json)
        self.init(announcement: announcement)
    }
}
