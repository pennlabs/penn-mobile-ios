//
//  HomeGSRCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeGSRCellItem: HomeCellItem {
    var title: String {
        return "Study Room Booking"
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeStudyRoomCell.self
    }
    
    func equals(item: HomeCellItem) -> Bool {
        return true
    }
    
    static var jsonKey: String {
        return "studyRoomBooking"
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        return HomeGSRCellItem()
    }
}
