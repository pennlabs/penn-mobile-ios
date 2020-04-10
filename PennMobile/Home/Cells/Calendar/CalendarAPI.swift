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
    
    let calendarUrl = "https://api.pennlabs.org/calendar/"
    
    var calendarEvents: [CalendarEvent]?
    
    func fetchCalendar(_ completion: @escaping (_ events: [CalendarEvent]?) -> Void) {
        
        getRequest(url: calendarUrl) { (dict, _, _) in
            guard let dict = dict else {
                completion(nil)
                return
            }
            let json = JSON(dict)
            if let jsonArray = json["calendar"].array {
                var events = [CalendarEvent]()
                for json in jsonArray {
                    let name = json["name"].stringValue
                    let start = json["start"].stringValue
                    let end = json["end"].stringValue
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    dateFormatter.timeZone = TimeZone(abbreviation: "EST")
                    let startDate = dateFormatter.date(from: start)!
                    let endDate = dateFormatter.date(from: end)!
                    
                    let event = CalendarEvent(name: name, start: startDate, end: endDate)
                    events.append(event)
                }
                //let exampleEvent: CalendarEvent = CalendarEvent(name: "Advance Registration Begins", start: Date() , end: Date())
                self.calendarEvents = events
                completion(events)
            }
        }
    }

}
