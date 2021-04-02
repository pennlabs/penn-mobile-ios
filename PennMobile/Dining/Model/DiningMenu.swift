//
//  DiningMenu.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 26/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

struct DiningMenuAPIResponse: Codable {
    let document: Document
    
    enum CodingKeys: String, CodingKey {
        case document = "Document"
    }
    
    struct Document: Codable {
        let dateString: String
        let menuDocument: MenuDocument
        
        enum CodingKeys: String, CodingKey {
            case dateString = "menudate"
            case menuDocument = "tblMenu"
        }
    }
}

struct MenuDocument: Codable {
    let menus: [DiningMenu]
    
    enum CodingKeys: String, CodingKey {
        case menus = "tblDayPart"
    }
}

struct DiningMenu: Codable, Hashable {

    let mealType: String
    let diningStations: [DiningStation]

    enum CodingKeys: String, CodingKey {
        case mealType = "txtDayPartDescription"
        case diningStations = "tblStation"
    }
}

struct DiningStation: Codable, Hashable {
    let stationDescription: String
    let diningStationItems: [DiningStationItem]
    
    enum CodingKeys: String, CodingKey {
        case stationDescription = "txtStationDescription"
        case diningStationItems = "tblItem"
    }
}

struct DiningStationItem: Codable, Hashable {
    
    let tableAttribute: Attribute
    let title: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case tableAttribute = "tblAttributes"
        case title = "txtTitle"
        case description = "txtDescription"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let data = try? container.decode(Attribute.self, forKey: .tableAttribute) {
            self.tableAttribute = data
        } else {
            self.tableAttribute = Attribute()
        }
        
//        self.tblFarmToFork = try! container.decode(String.self, forKey: .tblFarmToFork)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
    }
}

struct Attribute: Codable, Hashable {
    init() {
        attributeDescriptions = []
    }
    
    let attributeDescriptions: [AttributeDescription]
    
    enum CodingKeys: String, CodingKey {
        case attributeDescriptions = "txtAttribute"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let data = try? container.decode(AttributeDescription.self, forKey: .attributeDescriptions) {
            self.attributeDescriptions = [data]
        } else {
            let data = try container.decode([AttributeDescription].self, forKey: .attributeDescriptions)
            self.attributeDescriptions = data
        }
    }
}

struct AttributeDescription: Codable, Hashable {
    let description: String
}
