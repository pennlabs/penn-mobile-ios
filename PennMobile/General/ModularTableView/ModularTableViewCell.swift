//
//  ModularTableViewCell.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

protocol ModularTableViewCellDelegate {}

protocol ModularTableViewCell: class {
    static var identifier: String { get }
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat
    var item: ModularTableViewItem! { get set }
    var delegate: ModularTableViewCellDelegate! { get set }
}
