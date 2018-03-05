//
//  ModularTableViewItemTypes.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

protocol ModularTableViewItemTypes {
    var cellTypes: [ModularTableViewItem.Type] { get set }
    var tableView: UITableView! { get set }
}

extension ModularTableViewItemTypes {
    mutating func registerCells(for tableView: UITableView) {
        self.tableView = tableView
    }
    
    mutating func registerItemType(_ itemType: ModularTableViewItem.Type) {
        cellTypes.append(itemType)
        tableView.register(itemType.associatedCell, forCellReuseIdentifier: itemType.associatedCell.identifier)
    }
}
