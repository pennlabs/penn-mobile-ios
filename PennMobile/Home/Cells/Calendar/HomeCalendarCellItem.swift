//
//  HomeCalendarCellItem.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 11/6/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class HomeCalendarCellItem: HomeCellItem {
    
    static var jsonKey: String {
        return "calendar"
    }
    
    static func getHomeCellItem(_ completion: @escaping (([HomeCellItem]) -> Void)) {
        CalendarAPI.instance.fetchCalendar({ events in
            if let events = events, events.count > 0 {
                completion([HomeCalendarCellItem(for: events)])
            } else {
                completion([])
            }
        })
    }
    
    init(for events: [CalendarEvent]) {
        self.events = events
    }
    
    var events: [CalendarEvent]
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeCalendarCell.self
    }
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeCalendarCellItem else { return false }
        return events == item.events
    }
}
