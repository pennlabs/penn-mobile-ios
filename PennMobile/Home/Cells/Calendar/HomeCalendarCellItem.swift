//
//  HomeCalendarCellItem.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 11/6/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeCalendarCellItem: HomeCellItem {
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeCalendarCell.self
    }
    
    var events: [CalendarEvent]?
    
    func equals(item: HomeCellItem) -> Bool {
        guard let item = item as? HomeCalendarCellItem else { return false }
        guard let events = events, let itemEvents = item.events else { return false }
        return events == itemEvents
    }
    /*func equals(item: HomeCellItem) -> Bool {
        guard let item = item as? HomeCalendarCellItem else { return false }
        return events! == item.events!
    }*/
    
    static var jsonKey: String {
        return "calendar"
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        return HomeCalendarCellItem()
    }
    
}

// MARK: - API Fetching
extension HomeCalendarCellItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        CalendarAPI.instance.fetchCalendar { events in
            self.events = events
            completion()
        }
    }
}

