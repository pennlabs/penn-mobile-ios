//
//  HomeViewModelLaundryItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeViewModelLaundryItem: HomeViewModelItem {
    var title: String {
        return "Laundry"
    }
    
    static var associatedCell: HomeCellConformable.Type {
        return HomeLaundryCell.self
    }
    
    var room: LaundryRoom
    var timer: Timer?       // For decrementing machines
    
    init(room: LaundryRoom) {
        self.room = room
    }
    
    func equals(item: HomeViewModelItem) -> Bool {
        guard let item = item as? HomeViewModelLaundryItem else { return false }
        return room == item.room
    }
    
    static var jsonKey: String {
        return "laundry"
    }
    
    static func getItem(for json: JSON?) -> HomeViewModelItem? {
        guard let json = json else { return nil }
        return try? HomeViewModelLaundryItem(json: json)
    }
}
