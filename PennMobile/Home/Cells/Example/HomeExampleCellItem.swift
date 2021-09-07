//
//  HomeExampleCellItem.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 14/2/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit
import SwiftyJSON

final class HomeExampleCellItem: HomeCellItem {
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeExampleCell.self
    }
    
    var myData: String
    
    init(myData: String) {
        self.myData = myData
    }
    
    func equals(item: HomeCellItem) -> Bool {
        guard let item = item as? HomeExampleCellItem else { return false }
        return myData == item.myData
    }
    
    static var jsonKey: String {
        return "example" // Does not matter for this step
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        return HomeExampleCellItem(myData: "My example string")
    }
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeCoursesCellItem else { return false }
        return true
    }
    
}
