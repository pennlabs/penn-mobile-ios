//
//  HomeItemTypes.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeItemTypes: ModularTableViewItemTypes {
    static let instance = HomeItemTypes()
    private init() {}
    
    let dining: HomeCellItem.Type = HomeDiningCellItem.self
    let laundry: HomeCellItem.Type = HomeLaundryCellItem.self
    let studyRoomBooking: HomeCellItem.Type = HomeGSRCellItem.self
}

// MARK: - JSON Parsing
extension HomeItemTypes {
    func getItemType(for key: String) -> HomeCellItem.Type? {
        let mirror = Mirror(reflecting: self)
        for (_, itemType) in mirror.children {
            guard let itemType = itemType as? HomeCellItem.Type else { continue }
            if key == itemType.jsonKey {
                return itemType
            }
        }
        return nil
    }
}
