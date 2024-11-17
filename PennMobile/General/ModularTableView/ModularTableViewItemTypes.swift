//
//  ModularTableViewItemTypes.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

protocol ModularTableViewItemTypes: AnyObject {
    func registerCells(for tableView: UITableView)
}

extension ModularTableViewItemTypes {
    func registerCells(for tableView: UITableView) {
        let mirror = Mirror(reflecting: self)
        for (_, itemType) in mirror.children {
            guard let itemType = itemType as? ModularTableViewItem.Type else { continue }
            tableView.register(itemType.associatedCell, forCellReuseIdentifier: itemType.associatedCell.identifier)
        }
    }
}
