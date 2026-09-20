//
//  ModularTableView.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit
import PennMobileShared

final class ModularTableView: UITableView {
    var model: ModularTableViewModel! {
        didSet {
            self.dataSource = model
            self.delegate = model
        }
    }

    func registerTableView(for types: ModularTableViewItemTypes) {
        types.registerCells(for: self)
    }
    
    static let cellSpacing: CGFloat = Padding.pad * 2
}
