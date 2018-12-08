//
//  HomeCalendarCellItem2.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 12/7/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeCalendarCellItem2: HomeCellItem {
    
    static var jsonKey: String {
        return "calendar"
    }
    
    var events: [CalendarEvent]?
    
    init(defaultEvent: CalendarEvent) {
        CalendarAPI.instance.fetchCalendar { events in
            self.events = events
            //print(events!)
        }
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        return HomeCalendarCellItem2(defaultEvent: CalendarEvent.getDefaultCalendarEvent())
        // TODO: Implement me
        //guard let json = json else { return nil }
        //return try? HomeCalendarCellItem2(json: json)
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeCalendarCellTable.self
    }
    
    func equals(item: HomeCellItem) -> Bool {
        guard let item = item as? HomeCalendarCellItem2 else { return false }
        guard let events = events, let itemEvents = item.events else { return false }
        return events == itemEvents
    }
}

// MARK: - API Fetching
extension HomeCalendarCellItem2: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        CalendarAPI.instance.fetchCalendar { events in
            self.events = events
            print("fetched calendar items")
            print(events!)
            completion()
        }
    }
}

// MARK: - JSON Parsing
extension HomeCalendarCellItem2 {
    convenience init(json: JSON) throws {
        let event = CalendarEvent.getDefaultCalendarEvent()
        self.init(defaultEvent: event)
        print("initialized event")
    }
}

