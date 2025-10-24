//
//  CalendarAPI.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 11/16/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

class CalendarAPI: Requestable {

    static let instance = CalendarAPI()
    private init() {}

    let calendarUrl = "https://pennmobile.org/api/penndata/calendar/"

    var calendarEvents: [CalendarEvent]?

    func fetchCalendar(_ completion: @escaping (_ events: [CalendarEvent]?) -> Void) {
        getRequestData(url: calendarUrl) { (data, _, _) in
            guard let data = data else {
                completion(nil)
                return
            }

            let events = try? JSONDecoder().decode([CalendarEvent].self, from: data)
            self.calendarEvents = events
            completion(events)
        }
    }

}
