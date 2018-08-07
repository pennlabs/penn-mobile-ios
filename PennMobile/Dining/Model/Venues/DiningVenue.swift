//
//  DiningModel.swift
//  PennMobile
//
//  Created by Josh Doman on 4/23/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

enum DiningVenueType: String, Codable {
    case dining = "residential"
    case retail = "retail"
    
    func getFullDisplayName() -> String {
        switch self {
        case .dining: return "Campus Dining Hall"
        case .retail: return "Campus Retail Dining"
        }
    }
}

class DiningVenue: NSObject {
    
    static let diningNames: [DiningVenueName] = [.commons, .mcclelland, .nch, .hill, .english, .falk]
    static let retailNames: [DiningVenueName] = [.frontera, .gourmetGrocer, .houston, .joes, .marks, .beefsteak, .starbucks, .pret, .mbaCafe]
    
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
        return [.commons, .nch, .hill].map { DiningVenue(venue: $0) }
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
}

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
        guard let mapping = DiningVenue.idToVenue else { return nil }
        for (id, name) in mapping {
            if name == self.name.rawValue {
                return id
            }
        }
        return nil
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
        if self.times != nil && self.times!.isOpen {
            return .open
        } else if self.times != nil && !self.times!.isOpen {
            return .closed
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
