//
//  HomeCellItem
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

protocol HomeCellItem: ModularTableViewItem {
    func equals(item: HomeCellItem) -> Bool
    static var jsonKey: String { get }
    static func getItem(for json: JSON?) -> HomeCellItem?
}
