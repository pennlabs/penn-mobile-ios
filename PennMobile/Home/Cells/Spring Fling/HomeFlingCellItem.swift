//
//  HomeFlingCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/9/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeFlingCellItem: HomeCellItem {
    
    static var jsonKey: String {
        return "fling"
    }
    
    let performer: FlingPerformer
    
    init(performer: FlingPerformer) {
        self.performer = performer
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        let performer = FlingPerformer.getDefaultPerformer()
        return HomeFlingCellItem(performer: performer)
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeFlingCell.self
    }
    
    func equals(item: HomeCellItem) -> Bool {
        guard let item = item as? HomeFlingCellItem else { return false }
        return performer.name == item.performer.name
    }
}
