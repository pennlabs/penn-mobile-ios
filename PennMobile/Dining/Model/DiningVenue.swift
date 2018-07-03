//
//  DiningModel.swift
//  PennMobile
//
//  Created by Josh Doman on 4/23/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

enum DiningVenueType {
    case dining
    case retail
}

class DiningVenue: NSObject {
    
    static let diningNames: [DiningVenueName] = [.commons, .mcclelland, .nch, .hill, .english, .falk]
    static let retailNames: [DiningVenueName] = [.frontera, .gourmetGrocer, .houston, .joes, .marks, .beefsteak, .starbucks, .pret, .mbaCafe]
    
    var name: DiningVenueName
    
    var times: [OpenClose]? {
        return DiningHoursData.shared.getHours(for: name)
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
