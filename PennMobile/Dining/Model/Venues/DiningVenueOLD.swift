//
//  DiningModel.swift
//  PennMobile
//
//  Created by Josh on 4/23/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

struct DiningAPIResponse: Codable {
    let document: Document
    struct Document: Codable {
        let venues: [DiningVenue]
        
        enum CodingKeys: String, CodingKey {
            case venues = "venue"
        }
    }
}

struct DiningVenue: Codable {
    let dailyMenuURL: URL
    let dateHours: [MealsForDate]?
    let facilityURL: URL
    let id: Int
    let name: String
    let venueType: VenueType
    let weeklyMenuURL: String
    
    struct MealsForDate: Codable {
        let date: String
        let meals: [Meal]
        
        struct Meal: Codable {
            let open: String
            let close: String
            let type: String
            let date: String
        }
    }
    
    enum VenueType: String, Codable {
        case dining = "residential"
        case retail = "retail"
        case unknown = "unknown"
    }
}

extension DiningVenue.VenueType {
    public init(from decoder: Decoder) throws {
        self = try DiningVenue.VenueType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    func getFullDisplayName() -> String {
        switch self {
        case .dining: return "Campus Dining Hall"
        case .retail: return "Campus Retail Dining"
        case .unknown: return "Other"
        }
    }
}

// MARK: - Codable Stuff for MealsForDate
extension DiningVenue.MealsForDate {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let date = try container.decode(String.self, forKey: .date)
        
        let codableMeals = try container.decode(Array<CodableMeal>.self, forKey: .meals)
        let meals = codableMeals.map({ Meal(open: $0.open, close: $0.close, type: $0.type, date: date) })
        
        self.init(date: date, meals: meals)
    }
    
    enum CodingKeys: String, CodingKey {
        case date = "date"
        case meals = "meal"
    }
    
    struct CodableMeal: Codable {
        let open: String
        let close: String
        let type: String
    }
}

// CodableOpenClose is used to decode the JSON, and then it is mapped to OpenClose
// This is required because OpenClose needs to know the date string from one level higher

struct OpenClose: Equatable {
    let open: Date
    let close: Date
    let meal: String

//    static let completeformatter: DateFormatter = {
//        let df = DateFormatter()
//        df.dateFormat = "yyyy-MM-dd:HH:mm:ss"
//        df.timeZone = TimeZone(abbreviation: "EST")
//        return df
//    }()
    
    var description: String {
        return open.description + " - " + close.description
    }
    
    func overlaps(with oc: OpenClose) -> Bool {
        return (oc.open >= self.open && oc.open < self.close) || (self.open >= oc.open && self.open < oc.close)
    }
    
    func withoutMinutes() -> OpenClose {
        let newOpen = open.roundedDownToHour
        let newClose = close.roundedDownToHour
        return OpenClose(open: newOpen, close: newClose, meal: meal)
    }
}


fileprivate func getIdMapping(jsonArray: [JSON]) -> [Int: String] {
    var mapping = [Int: String]()
    for json in jsonArray {
        let name = json["name"].stringValue
        let id = json["id"].intValue
        mapping[id] = name
    }
    return mapping
}



/*class DiningVenue: NSObject {
    
    static let diningNames: [DiningVenueName] = [.commons, .mcclelland, .lauder, .hill, .english, .falk]
    static let retailNames: [DiningVenueName] = [.houston, .gourmetGrocer, .joes, .starbucks, .pret, .mbaCafe]
    
    var name: DiningVenueName
    
    var times: [OpenClose]? {
        return DiningHoursData.shared.getHours(for: name)
    }
    
    func times(on day: String) -> [OpenClose]? {
        return DiningHoursData.shared.getHours(for: name, on: day)
    }
    
    var timeStringsForWeek: [String] {
        var timesForDay = [String]()
        let dateStringsForCurrentWeek = Date().dateStringsForCurrentWeek
        for day in dateStringsForCurrentWeek {
            if let timesOnDay = times(on: day) {
                timesForDay.append(timesOnDay.strFormat)
            } else {
                timesForDay.append("Closed")
            }
        }
        return timesForDay
    }
    
    var meals: [DiningMeal]? {
        return DiningMenuData.shared.getMeals(for: name)
    }
    
    init(venue: DiningVenueName) {
        self.name = venue
    }
    
    static func getDefaultVenues() -> [DiningVenue] {
        return [.commons, .lauder, .hill].map { DiningVenue(venue: $0) }
    }
    
    static func getVenues(for type: DiningVenueType) -> [DiningVenue] {
        let names: [DiningVenueName]
        switch type {
        case .dining:
            names = diningNames
        case .retail:
            names = retailNames
        }
        
        return names.map { DiningVenue(venue: $0) }
    }
}*/

// MARK: - Caching
extension DiningVenue {
    static let directory = "diningVenueDirectory"
    private static var idToVenue: [Int: String]?
    
    convenience init(id: Int) throws {
        if DiningVenue.idToVenue == nil && Storage.fileExists(DiningVenue.directory, in: .caches) {
            DiningVenue.idToVenue = Storage.retrieve(DiningVenue.directory, from: .caches, as: Dictionary<Int, String>.self)
        }
        
        guard let venueName = DiningVenue.idToVenue?[id], let venue = DiningVenueName(rawValue: venueName) else {
            throw NetworkingError.other
        }
        self.init(venue: venue)
    }
    
    func getID() -> Int? {
//        guard let mapping = DiningVenue.idToVenue else { return nil }
//        for (id, name) in mapping {
//            if name == self.name.rawValue {
//                return id
//            }
//        }
//        return nil
        let id = self.name.getID()
        return id
    }
}

// MARK: - Building Detail Protocol Methods
extension DiningVenue: BuildingDetailDisplayable {
    func cellsToDisplay() -> [BuildingCellType] {
        return [.title, .image, .weekHours, .foodMenu, .map]
    }
    
    func numberOfCellsToDisplay() -> Int {
        return 5
    }
    
    func getBuildingType() -> BuildingType {
        return .diningHall
    }
}

// MARK: - Building Header Displayable
extension DiningVenue: BuildingHeaderDisplayable {
    func getTitle() -> String {
        return DiningVenueName.getVenueName(for: self.name)
    }
    
    func getSubtitle() -> String {
        return DiningVenueName.getType(for: self.name).getFullDisplayName()
    }
    
    func getStatus() -> BuildingHeaderState {
        if let times = self.times, !times.isEmpty {
            return times.isOpen ? .open : .closed
        } else {
            return .closedToday
        }
    }
}

// MARK: - Building Image Displayable
extension DiningVenue: BuildingImageDisplayable {
    func getImage() -> String {
        return self.name.rawValue.folding(options: .diacriticInsensitive, locale: .current)
    }
}

// MARK: - Building Hours Displayable
extension DiningVenue: BuildingHoursDisplayable {
    func getTimeStrings() -> [String] {
        return self.timeStringsForWeek
    }
}

// MARK: - Building Menus Displayable
extension DiningVenue: BuildingMenusDisplayable {
    func getMeals() -> [DiningMeal]? {
        return self.meals
    }
    func getTimes() -> [OpenClose]? {
        return self.times
    }
}

// MARK: - Building Map Displayable
import MapKit
extension DiningVenue: BuildingMapDisplayable {
    func getRegion() -> MKCoordinateRegion {
        return PennCoordinate.shared.getRegion(for: self.name, at: .close)
    }
    
    func getAnnotation() -> MKAnnotation {
        return PennCoordinate.shared.getAnnotation(for: self.name)
    }
}

// MARK: - Array Extension
extension Array where Element == OpenClose {
    func containsOverlappingTime(with oc: OpenClose) -> Bool {
        for e in self {
            if e.overlaps(with: oc) { return true }
        }
        return false
    }
    
    mutating func removeAllMinutes() {
        self = self.map({ (oc) -> OpenClose in
            oc.withoutMinutes()
        })
    }
    
    var isOpen: Bool {
        let now = Date()
        for open_close in self {
            if open_close.open < now && open_close.close > now {
                return true
            }
        }
        return false
    }
    
    var nextOpen: OpenClose? {
        let now = Date()
        for index in self.indices {
            let open_close = self[index]
            
            // If the call is currently open, return the current timeslot
            if open_close.open < now && open_close.close > now { return open_close }
            
            // If the hall is closed but about to open again, return the next timeslot
            if index + 1 < self.count {
                if self[index].close < now && self[index + 1].open > now { return self[index + 1] }
            }
        }
        return nil
    }
    
    var strFormat: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "EST")
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "a"
        formatter.pmSymbol = "p"
        
        var firstOpenClose = true
        var timesString = ""
        
        for open_close in self {
            if open_close.open.minutes == 0 {
                formatter.dateFormat = self.count > 1 ? "h" : "ha"
            } else {
                formatter.dateFormat = self.count > 1 ? "h:mm" : "h:mma"
            }
            let open = formatter.string(from: open_close.open)
            
            if open_close.close.minutes == 0 {
                formatter.dateFormat = self.count > 1 ? "h" : "ha"
            } else {
                formatter.dateFormat = self.count > 1 ? "h:mm" : "h:mma"
            }
            let close = formatter.string(from: open_close.close)
            
            if firstOpenClose {
                firstOpenClose = false
            } else {
                timesString += "  |  "
            }
            timesString += "\(open) - \(close)"
        }
        
        if self.isEmpty {
            timesString = ""
        }
        return timesString
    }
}
