//
//  DiningMenu.swift
//  PennMobile
//
//  Created by Dominic on 7/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

struct DiningMenuDocument: Codable {
    let document: DiningMenu
    
    enum CodingKeys : String, CodingKey {
        case document = "Document"
    }
}

struct DiningMenu: Codable {
    let location: String
    let date: String
    let menu: DiningDayMenu
    
    enum CodingKeys : String, CodingKey {
        case location = "location"
        case date = "menudate"
        case menu = "tblMenu"
    }
}

struct DiningDayMenu: Codable {
    let meals: [DiningMeal]
    
    enum CodingKeys : String, CodingKey {
        case meals = "tblDayPart"
    }
}

struct DiningMeal: Codable {
    let stations: [DiningStation]
    let description: String
    
    enum CodingKeys : String, CodingKey {
        case stations = "tblStation"
        case description = "txtDayPartDescription"
    }
    
    func usefulStations() -> [DiningStation] {
        var filteredStations = [DiningStation]()
        let filterWords = ["beverage", "soda", "sandwich", "coffee", "salad", "dessert", "condiment"]
        for station in stations {
            if !filterWords.contains(where: station.description.contains) {
                filteredStations.append(station)
            }
        }
        return filteredStations
    }
}

struct DiningStation: Codable {
    let menuItem: [MenuItem]
    let description: String
    
    enum CodingKeys : String, CodingKey {
        case menuItem = "tblItem"
        case description = "txtStationDescription"
    }
}

struct MenuItem: Codable {
    let attributes: MenuItemAttributes?
    let title: String
    let description: String
    
    enum CodingKeys : String, CodingKey {
        case attributes = "tblAttributes"
        case title = "txtTitle"
        case description = "txtDescription"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        do {
            self.attributes = try container.decodeIfPresent(MenuItemAttributes.self, forKey: .attributes)
        } catch {
            self.attributes = nil
        }
    }
}

struct MenuItemAttributes: Codable {
    let attributes: [DiningAttribute]
    enum CodingKeys : String, CodingKey {
        case attributes = "txtAttribute"
    }
}

struct DiningAttribute: Codable {
    let description: DiningAttributeType
}

enum DiningAttributeType : String, Codable {
    case vegetarian = "Vegetarian"
    case gluten = "Made without Gluten- Containing Ingredients"
    case farm = "Farm to Fork"
    case vegan = "Vegan"
    case seafood = "Seafood Watch"
    case humane = "Humane"
}

