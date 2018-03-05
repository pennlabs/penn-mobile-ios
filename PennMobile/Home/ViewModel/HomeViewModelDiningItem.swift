//
//  HomeViewModelDiningitem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeViewModelDiningItem: HomeViewModelItem {
    var title: String {
        return "Dining"
    }
    
    static var associatedCell: HomeCellConformable.Type {
        return HomeDiningCell.self
    }
    
    var venues: [DiningVenue]
    
    init(venues: [DiningVenue]) {
        self.venues = venues
    }
    
    func equals(item: HomeViewModelItem) -> Bool {
        guard let item = item as? HomeViewModelDiningItem else { return false }
        return venues == item.venues
    }
    
    static var jsonKey: String {
        return "dining"
    }
    
    static func getItem(for json: JSON?) -> HomeViewModelItem? {
        guard let json = json else { return nil }
        return try? HomeViewModelDiningItem(json: json)
    }
}
