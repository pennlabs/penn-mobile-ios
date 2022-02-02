//
//  HomeFeatureCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class HomeFeatureCellItem: HomeCellItem {
    static func getHomeCellItem(_ completion: @escaping (([HomeCellItem]) -> Void)) {
        completion([])
    }

    static var jsonKey: String {
        return "feature"
    }

    let announcement: FeatureAnnouncement
    var image: UIImage?
    var showSubtitle = false

    init(announcement: FeatureAnnouncement) {
        self.announcement = announcement
    }

    static var associatedCell: ModularTableViewCell.Type {
        return HomeFeatureCell.self
    }

    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeFeatureCellItem else { return false }
        return announcement.title == item.announcement.title
    }
}
