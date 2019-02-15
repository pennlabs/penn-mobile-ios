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
    
    func equals(item: HomeCellItem) -> Bool {
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
        print(json)
        var venues: [DiningVenue] = ids.map { try? DiningVenue(id: $0) }.filter { $0 != nil}.map { $0! }
        if venues.isEmpty {
            venues = DiningVenue.getDefaultVenues()
        }
        self.init(venues: venues)
    }
}

// MARK: - API Fetching
extension HomeDiningCellItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        DiningAPI.instance.fetchDiningHours { _ in
            completion()
        }
    }
}
