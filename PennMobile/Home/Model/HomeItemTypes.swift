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
    
    //let fling: HomeCellItem.Type = HomeFlingCellItem.self
    let dining: HomeCellItem.Type = HomeDiningCellItem.self
    let laundry: HomeCellItem.Type = HomeLaundryCellItem.self
    let studyRoomBooking: HomeCellItem.Type = HomeGSRCellItem.self
    let calendar: HomeCellItem.Type = HomeCalendarCellItem.self
    let news: HomeCellItem.Type = HomeNewsCellItem.self
    let post: HomeCellItem.Type = HomePostCellItem.self
    let feature: HomeCellItem.Type = HomeFeatureCellItem.self
    let reservations: HomeCellItem.Type = HomeReservationsCellItem.self
    let courses: HomeCellItem.Type = HomeCoursesCellItem.self
    let gsrLocations: HomeCellItem.Type = HomeGSRLocationsCellItem.self
    let invites: HomeCellItem.Type =  HomeGroupInvitesCellItem.self
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

// MARK: Default Cells for Development Purposes
extension HomeItemTypes {
    /**
     * Purpose: For building a new cell that is not yet on the API
     * Usage:   1) Add cell type to HomeItemTypes
     *          2) Append cell type to types array below
     *          3) Initialize item in its class (ex: HomeNewsCellItem)
     *
     * Ex:  (1) let news: HomeCellItem.Type = HomeNewsCellItem.self (in HomeItemTypes)
     *
     *      (2) var types = [HomeCellItem.Type]()
     *          types.append(news)
     *          return types
     *
     *      (3) static func getItem(for json: JSON?) -> HomeCellItem? {
     *              return HomeNewsCellItem()
     *          }
     *
     * Note: This method should return an empty array when the app is in production
    **/
    func getDefaultItems() -> [HomeCellItem.Type] {
        let types = [HomeCellItem.Type]()
        return types
    }
}
