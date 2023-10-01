//
//  HomeDiningCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON
import PennMobileShared

final class HomeDiningCellItem: HomeCellItem {

    static var jsonKey: String {
        return "dining"
    }

    static var associatedCell: ModularTableViewCell.Type {
        return HomeDiningCell.self
    }

    var venues: [DiningVenue]

    init(for venues: [DiningVenue]) {
        self.venues = venues
    }

    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeDiningCellItem else { return false }
        return venues == item.venues
    }

    static func getHomeCellItem(_ completion: @escaping((_ items: [HomeCellItem]) -> Void)) {
        UserDBManager.shared.fetchDiningPreferences { result in
            if let venues = try? result.get() {
                if venues.count == 0 {
                    completion([HomeDiningCellItem(for: DiningAPI.instance.getVenues(with: DiningVenue.defaultVenueIds))])
                } else {
                    completion([HomeDiningCellItem(for: venues)])
                }
            } else {
                completion([])
            }
        }
    }
}
