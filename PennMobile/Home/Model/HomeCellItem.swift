//
//  HomeCellItem
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

protocol HomeCellItem: ModularTableViewItem {
    static var jsonKey: String { get }
    static func getItem(for json: JSON?) -> HomeCellItem?
}

protocol LoggingIdentifiable where Self: HomeCellItem {
    var id: String { get }
}

protocol Testable where Self: HomeCellItem {
    var isTest: Bool { get }
}
