//
//  HomeEventCellItem.swift
//  PennMobile
//
//  Created by Carin Gan on 11/4/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeEventCellItem: HomeCellItem {
    
    static var jsonKey: String {
        return "event"
    }
    
    let event: Event
    var image: UIImage?
    
    init(event: Event) {
        self.event = event
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        guard let json = json else { return nil }
        return try? HomeEventCellItem(json: json)
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeEventCell.self
    }
    
    func equals(item: HomeCellItem) -> Bool {
        guard let item = item as? HomeEventCellItem else { return false }
        return event.name == item.event.name
    }
}

// MARK: - HomeAPIRequestable
extension HomeEventCellItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        ImageNetworkingManager.instance.downloadImage(imageUrl: event.imageUrl) { (image) in
            self.image = image
            completion()
        }
    }
}

// MARK: - JSON Parsing
extension HomeEventCellItem {
    convenience init(json: JSON) throws {
        let event = try Event(json: json)
        self.init(event: event)
    }
}

// MARK: - Sorting
extension HomeEventCellItem: Comparable {
    static func <(lhs: HomeEventCellItem, rhs: HomeEventCellItem) -> Bool {
        let now = Date()
        if (lhs.event.endTime > now && rhs.event.endTime > now) || (lhs.event.endTime < now && rhs.event.endTime < now) {
            return lhs.event.startTime < rhs.event.startTime
        }
        return lhs.event.endTime > now
    }
    
    static func ==(lhs: HomeEventCellItem, rhs: HomeEventCellItem) -> Bool {
        return lhs.event.name == rhs.event.name && lhs.event.startTime == rhs.event.startTime
    }
}

extension Array where Element == HomeEventCellItem {
    func equals(_ items: [HomeEventCellItem]) -> Bool {
        return self.map { $0.event }.equals(items.map { $0.event })
    }
}
