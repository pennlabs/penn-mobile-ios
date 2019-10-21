//
//  OpenClose.swift
//  PennMobile
//
//  Created by Josh Doman on 1/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

//import Foundation

//struct DiningVenueForWeek: Codable {
//    let dailyMenuURL: String
//    let dateHours: [DiningVenueDateHours]?
//    let facilityURL: String
//    let id: Int
//    let name: String
//    let venueType: DiningVenueType
//    let weeklyMenuURL: String
//}
//
//struct DiningVenueDateHours: Codable {
//    let date: String
//    let meal: [CodableOpenClose]
//}
//
//struct CodableOpenClose: Codable {
//    let open: String
//    let close: String
//    let meal: String
//
//    enum CodingKeys: String, CodingKey {
//        case open = "open"
//        case close = "close"
//        case meal = "type"
//    }
//}
//
//// CodableOpenClose is used to decode the JSON, and then it is mapped to OpenClose
//// This is required because OpenClose needs to know the date string from one level higher
//
//struct OpenClose: Equatable {
//    let open: Date
//    let close: Date
//    let meal: String
//
//    static let completeformatter: DateFormatter = {
//        let df = DateFormatter()
//        df.dateFormat = "yyyy-MM-dd:HH:mm:ss"
//        df.timeZone = TimeZone(abbreviation: "EST")
//        return df
//    }()
//
//    var description: String {
//        return open.description + " - " + close.description
//    }
//
//    func overlaps(with oc: OpenClose) -> Bool {
//        return (oc.open >= self.open && oc.open < self.close) || (self.open >= oc.open && self.open < oc.close)
//    }
//
//    func withoutMinutes() -> OpenClose {
//        let newOpen = open.roundedDownToHour
//        let newClose = close.roundedDownToHour
//        return OpenClose(open: newOpen, close: newClose, meal: meal)
//    }
//}
//
//// MARK: - Array Extension
//extension Array where Element == OpenClose {
//    func containsOverlappingTime(with oc: OpenClose) -> Bool {
//        for e in self {
//            if e.overlaps(with: oc) { return true }
//        }
//        return false
//    }
//
//    mutating func removeAllMinutes() {
//        self = self.map({ (oc) -> OpenClose in
//            oc.withoutMinutes()
//        })
//    }
//
//    var isOpen: Bool {
//        let now = Date()
//        for open_close in self {
//            if open_close.open < now && open_close.close > now {
//                return true
//            }
//        }
//        return false
//    }
//
//    var nextOpen: OpenClose? {
//        let now = Date()
//        for index in self.indices {
//            let open_close = self[index]
//
//            // If the call is currently open, return the current timeslot
//            if open_close.open < now && open_close.close > now { return open_close }
//
//            // If the hall is closed but about to open again, return the next timeslot
//            if index + 1 < self.count {
//                if self[index].close < now && self[index + 1].open > now { return self[index + 1] }
//            }
//        }
//        return nil
//    }
//
//    var strFormat: String {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone(abbreviation: "EST")
//        formatter.dateFormat = "h:mma"
//        formatter.amSymbol = "a"
//        formatter.pmSymbol = "p"
//
//        var firstOpenClose = true
//        var timesString = ""
//
//        for open_close in self {
//            if open_close.open.minutes == 0 {
//                formatter.dateFormat = self.count > 1 ? "h" : "ha"
//            } else {
//                formatter.dateFormat = self.count > 1 ? "h:mm" : "h:mma"
//            }
//            let open = formatter.string(from: open_close.open)
//
//            if open_close.close.minutes == 0 {
//                formatter.dateFormat = self.count > 1 ? "h" : "ha"
//            } else {
//                formatter.dateFormat = self.count > 1 ? "h:mm" : "h:mma"
//            }
//            let close = formatter.string(from: open_close.close)
//
//            if firstOpenClose {
//                firstOpenClose = false
//            } else {
//                timesString += "  |  "
//            }
//            timesString += "\(open) - \(close)"
//        }
//
//        if self.isEmpty {
//            timesString = ""
//        }
//        return timesString
//    }
//}
