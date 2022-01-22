//
//  HomeCellItem
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol HomeCellItem: ModularTableViewItem {
    static var jsonKey: String { get }
    static func getHomeCellItem(_ completion: @escaping((_ item: [HomeCellItem]) -> Void))
}

extension HomeCellItem {
    var cellIdentifier: String {
        return Self.jsonKey
    }
}


protocol LoggingIdentifiable where Self: HomeCellItem {
    var id: String { get }
}
