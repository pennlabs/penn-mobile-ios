//
//  HomeGSRCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class HomeGSRCellItem: HomeCellItem {
    static func getHomeCellItem(_ completion: @escaping (([HomeCellItem]) -> Void)) {
        completion([])
    }

    static var associatedCell: ModularTableViewCell.Type {
        return HomeStudyRoomCell.self
    }

    var title: String {
        return "Study Room Booking"
    }
    
    init() {
    }
    
    var bookingOptions: [[GSRBooking?]]?
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let _ = item as? HomeGSRCellItem else { return false }
        return true
    }
    
    static var jsonKey: String {
        return "studyRoomBooking"
    }
}
