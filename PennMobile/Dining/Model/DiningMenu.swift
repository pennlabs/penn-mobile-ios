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
        let location: String
        let dateString: String
        let menuDocument: MenuDocument
        
        enum CodingKeys: String, CodingKey {
            case location = "location"
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

struct DiningMenu: Codable {
    let mealType: String
    let stations: [DiningStation]

    enum CodingKeys: String, CodingKey {
        case mealType = "txtDayPartDescription"
        case stations = "tblStation"
    }
}

struct DiningStation: Codable {
    let stationDescription: String
    let diningStationItems: [DiningStationItem]
    
    enum CodingKeys: String, CodingKey {
        case stationDescription = "txtStationDescription"
        case diningStationItems = "tblItem"
    }
}

struct DiningStationItem: Codable {
    
    struct Attribute: Codable {
        init() {
            txtAttribute = []
        }
        
        let txtAttribute: [Description] //?  Description
        
        struct Description: Codable {
            let description: String
        }
        
        enum CodingKeys: String, CodingKey {
            case txtAttribute
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let data = try? container.decode(Description.self, forKey: .txtAttribute) {
                self.txtAttribute = [data]
            } else {
                let data = try container.decode([Description].self, forKey: .txtAttribute)
                self.txtAttribute = data
            }
        }
    }
    
    let tableAttributes: Attribute

    enum CodingKeys: String, CodingKey {
        case tableAttributes = "tblAttributes"
        case tblFarmToFork
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let data = try? container.decode(Attribute.self, forKey: .tableAttributes) {
            self.tableAttributes = data
        } else {
            self.tableAttributes = Attribute()
        }
        
        self.tblFarmToFork = try! container.decode(String.self, forKey: .tblFarmToFork)
    }

    let tblFarmToFork: String
//    let tblSide: String
//    let txtDescription: String
//    let txtNutritionInfo: String
//    let txtPrice: String
//    let txtTitle: String
}
