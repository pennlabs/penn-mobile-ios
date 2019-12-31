//
//  UpdateVersionCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 12/30/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

final class UpdateVersionCellItem: HomeCellItem {
    static var associatedCell: ModularTableViewCell.Type {
        return UpdateVersionCell.self
    }

    func equals(item: ModularTableViewItem) -> Bool {
        return item is UpdateVersionCellItem
    }
    
    static var jsonKey: String {
        return "new-version-released"
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        return UpdateVersionCellItem()
    }
}
