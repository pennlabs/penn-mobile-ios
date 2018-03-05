//
//  HomeLaundryCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeLaundryCellItem: HomeCellItem {
    static var associatedCell: ModularTableViewCell.Type {
        return HomeLaundryCell.self
    }
    
    var room: LaundryRoom
    
    init(room: LaundryRoom) {
        self.room = room
    }
    
    func equals(item: HomeCellItem) -> Bool {
        guard let item = item as? HomeLaundryCellItem else { return false }
        return room == item.room
    }
    
    static var jsonKey: String {
        return "laundry"
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        guard let json = json else { return nil }
        return try? HomeLaundryCellItem(json: json)
    }
}

// MARK: - JSON Parsing
extension HomeLaundryCellItem {
    convenience init(json: JSON) throws {
        let id = json["room_id"].intValue
        let room: LaundryRoom
        if let laundryRoom = LaundryAPIService.instance.idToRooms?[id] {
            room = laundryRoom
        } else {
            room = LaundryRoom.getPreferences().first!
        }
        self.init(room: room)
    }
}

// MARK: - API Fetching
extension HomeLaundryCellItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        LaundryNotificationCenter.shared.updateForExpiredNotifications {
            LaundryAPIService.instance.fetchLaundryData(for: [self.room]) { (rooms) in
                if let room = rooms?.first {
                    self.room = room
                }
                completion()
            }
        }
    }
}
