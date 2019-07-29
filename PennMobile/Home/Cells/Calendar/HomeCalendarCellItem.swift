//
//  HomeCalendarCellItem.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 11/6/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeCalendarCellItem: HomeCellItem {
    
    static var jsonKey: String {
        return "calendar"
    }
    
    var events: [CalendarEvent]?
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        return HomeCalendarCellItem()
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeCalendarCell.self
    }
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeCalendarCellItem else { return false }
        guard let events = events, let itemEvents = item.events else { return false }
        return events == itemEvents
    }
}

// MARK: - API Fetching
extension HomeCalendarCellItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        CalendarAPI.instance.fetchCalendar { events in
            if let top2Events = events?.prefix(2) {
                self.events = Array(top2Events)
            }
            completion()
        }
    }
}

