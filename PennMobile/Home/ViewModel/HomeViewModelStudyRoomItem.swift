//
//  HomeViewModelStudyRoomItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeViewModelStudyRoomItem: HomeViewModelItem {
    var title: String {
        return "Study Room Booking"
    }
    
    static var associatedCell: HomeCellConformable.Type {
        return HomeStudyRoomCell.self
    }
    
    func equals(item: HomeViewModelItem) -> Bool {
        return true
    }
    
    static var jsonKey: String {
        return "studyRoomBooking"
    }
    
    static func getItem(for json: JSON?) -> HomeViewModelItem? {
        return HomeViewModelStudyRoomItem()
    }
}
