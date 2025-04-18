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

    // let fling: HomeCellItem.Type = HomeFlingCellItem.self
    let dining: HomeCellItem.Type = HomeDiningCellItem.self
    let laundry: HomeCellItem.Type = HomeLaundryCellItem.self
    let studyRoomBooking: HomeCellItem.Type = HomeGSRCellItem.self
    let calendar: HomeCellItem.Type = HomeCalendarCellItem.self
    let news: HomeCellItem.Type = HomeNewsCellItem.self
    let post: HomeCellItem.Type = HomePostCellItem.self
    let feature: HomeCellItem.Type = HomeFeatureCellItem.self
    let reservations: HomeCellItem.Type = HomeReservationsCellItem.self
    let gsrLocations: HomeCellItem.Type = HomeGSRLocationsCellItem.self
    let invites: HomeCellItem.Type =  HomeGroupInvitesCellItem.self
    // let update: HomeCellItem.Type = HomeUpdateCellItem.self
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

extension HomeItemTypes {
    func getAllTypes() -> [HomeCellItem.Type] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.map { $0.value as! HomeCellItem.Type }
    }
}
