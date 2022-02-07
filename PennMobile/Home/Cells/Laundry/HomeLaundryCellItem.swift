//
//  HomeLaundryCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class HomeLaundryCellItem: HomeCellItem {
    static var associatedCell: ModularTableViewCell.Type {
        return HomeLaundryCell.self
    }

    static func getHomeCellItem(_ completion: @escaping (([HomeCellItem]) -> Void)) {
        UserDBManager.shared.getLaundryPreferences { result in
            if let ids = result, ids.count > 0 {
                LaundryAPIService.instance.fetchLaundryData(for: ids) { rooms in
                    if let rooms = rooms, rooms.count > 0 {
                        completion([HomeLaundryCellItem(room: rooms[0])])
                    } else {
                        completion([])
                    }
                }
            } else {
                completion([])
            }
        }
    }

    var room: LaundryRoom

    init(room: LaundryRoom) {
        self.room = room
    }

    func equals(item: ModularTableViewItem) -> Bool {
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
        if let laundryRoom = LaundryRoom.getLaundryHall(for: id) {
            room = laundryRoom
        } else if let laundryRoom = LaundryRoom.getPreferences().first {
            room = laundryRoom
        } else {
            room = LaundryRoom.getDefaultRoom()
        }
        self.init(room: room)
    }
}
