//
//  HomeCalendarCellItem.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 11/6/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeCalendarCellItem: HomeCellItem {
    static var associatedCell: ModularTableViewCell.Type {
        return HomeCalendarCell.self
    }
    
    var myData: String
    
    init(myData: String) {
        self.myData = myData
    }
    
    func equals(item: HomeCellItem) -> Bool {
        guard let item = item as? HomeCalendarCellItem else { return false }
        return myData == item.myData
    }
    
    static var jsonKey: String {
        return "example" // Does not matter for this step
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        return HomeCalendarCellItem(myData: "My example string")
    }
}
