//
//  HomeDiningCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class HomeDiningCellItem: HomeCellItem {
    static var associatedCell: ModularTableViewCell.Type {
        return HomeDiningCell.self
    }
    
    var venues: [DiningVenue]
    var venueIds: [Int]
    
    init(venues: [DiningVenue], venueIds: [Int]) {
        self.venues = venues
        self.venueIds = venueIds
    }
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeDiningCellItem else { return false }
        return venues == item.venues
    }
    
    static var jsonKey: String {
        return "dining"
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        guard let json = json else { return nil }
        return try? HomeDiningCellItem(json: json)
    }
}

// MARK: - JSON Parsing
extension HomeDiningCellItem {
    convenience init(json: JSON) throws {
        guard let ids = json["venues"].arrayObject as? [Int] else {
            throw NetworkingError.jsonError
        }
        let venues: [DiningVenue] = DiningDataStore.shared.getVenues(with: ids)
        self.init(venues: venues, venueIds: ids)
    }
}

// MARK: - API Fetching
extension HomeDiningCellItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        DiningAPI.instance.fetchDiningHours { _,_  in
            if self.venues.isEmpty {
                self.venues = DiningDataStore.shared.getVenues(with: self.venueIds)
            }
            completion()
        }
    }
}
