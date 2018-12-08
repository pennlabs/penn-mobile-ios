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
    var event: CalendarEvent
    
    init(event: CalendarEvent) {
        //self.events = events
        self.event = CalendarEvent.getDefaultCalendarEvent()
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        return HomeCalendarCellItem(event: CalendarEvent.getDefaultCalendarEvent())
        // TODO: Implement me
        guard let json = json else { return nil }
        return try? HomeCalendarCellItem(json: json)
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeCalendarCell.self
    }
    
    func equals(item: HomeCellItem) -> Bool {
        guard let item = item as? HomeCalendarCellItem else { return false }
        guard let events = events, let itemEvents = item.events else { return false }
        return events == itemEvents
    }
}

// MARK: - API Fetching
extension HomeCalendarCellItem: HomeAPIRequestable {
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
extension HomeCalendarCellItem {
    convenience init(json: JSON) throws {
        let event = CalendarEvent.getDefaultCalendarEvent()
        //let events = try CalendarEvent(json: json)
        self.init(event: event)
        print("initialized event")
    }
}

