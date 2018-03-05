//
//  HomeItemTypes.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

struct HomeItemTypes {
    static let instance: HomeItemTypes = HomeItemTypes()
    private init() {}
    
    let dining: HomeViewModelItem.Type = HomeViewModelDiningItem.self
    let laundry: HomeViewModelItem.Type = HomeViewModelLaundryItem.self
    let studyRoomBooking: HomeViewModelItem.Type = HomeViewModelStudyRoomItem.self
    
    func getItemType(for key: String) -> HomeViewModelItem.Type? {
        let mirror = Mirror(reflecting: self)
        for (_, itemType) in mirror.children {
            guard let itemType = itemType as? HomeViewModelItem.Type else { continue }
            if key == itemType.jsonKey {
                return itemType
            }
        }
        return nil
    }
    
    func registerCells(for tableView: UITableView) {
        let mirror = Mirror(reflecting: self)
        for (_, itemType) in mirror.children {
            guard let itemType = itemType as? HomeViewModelItem.Type else { continue }
            tableView.register(itemType.associatedCell, forCellReuseIdentifier: itemType.associatedCell.identifier)
        }
    }
}
