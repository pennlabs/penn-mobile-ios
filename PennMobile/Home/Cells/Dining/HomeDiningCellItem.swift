//
//  HomeDiningCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeDiningCellItem: HomeCellItem {
    static var associatedCell: ModularTableViewCell.Type {
        return HomeDiningCell.self
    }
    
    var venues: [DiningVenue]
    
    init(venues: [DiningVenue]) {
        self.venues = venues
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
        var venues: [DiningVenue] = DiningDataStore.shared.getVenues(with: ids)
        if venues.isEmpty {
            // If the user has no preferences, use the defaults
            venues = DiningDataStore.shared.getVenues(with: DiningVenue.defaultVenueIds)
        }
        self.init(venues: venues)
    }
}

// MARK: - API Fetching
extension HomeDiningCellItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        DiningAPI.instance.fetchDiningHours { _,_  in
            completion()
        }
    }
}
