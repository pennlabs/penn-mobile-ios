//
//  ModularTableViewItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

protocol ModularTableViewItem {
    static var associatedCell: ModularTableViewCell.Type { get }
    func equals(item: ModularTableViewItem) -> Bool
}

extension ModularTableViewItem {
    var cellIdentifier: String {
        return Self.associatedCell.identifier
    }
    
    var cellHeight: CGFloat {
        return Self.associatedCell.getCellHeight(for: self) + HomeViewController.cellSpacing
    }
}
