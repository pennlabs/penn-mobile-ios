//
//  DiningMenu.swift
//  PennMobile
//
//  Created by Dominic on 7/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

struct DiningMenuDocument: Codable {
    let Document: DiningMenu
}

struct DiningMenu: Codable {
    let location: String
    let menudate: String
    let tblMenu: TableMenu
}

struct TableMenu: Codable {
    let tblDayPart: [TableDayPart]
}

struct TableDayPart: Codable {
    let tblStation: [TableStation]
    let txtDayPartDescription: String
}

struct TableStation: Codable {
    let tblItem: [TableItem]
    let txtStationDescription: String
}

struct TableItem: Codable {
    let tblAttributes: TextAttribute?
    /*tblFarmToFork: "",
     tblSide: "",
     txtDescription: "local cage free eggs lightly seasoned with kosher salt and black pepper, scrambled to perfection&lt;br /&gt;common market philadelphia",
     txtNutritionInfo: "",
     txtPrice: "",
     txtTitle: "scrambled eggs"*/
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.tblAttributes = try container.decodeIfPresent(TextAttribute.self,
                                                               forKey: .tblAttributes)
        } catch {
            self.tblAttributes = nil
        }
    }
}

struct TextAttribute: Codable {
    let attributes: [DiningAttribute]
    enum CodingKeys : String, CodingKey {
        case attributes = "txtAttribute"
    }
}

struct DiningAttribute: Codable {
    let description: String
}
