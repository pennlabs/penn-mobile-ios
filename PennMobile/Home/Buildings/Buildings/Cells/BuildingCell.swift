//
//  BuildingCell.swift
//  PennMobile
//
//  Created by dominic on 6/21/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

protocol CellUpdateDelegate: AnyObject {
    func cellRequiresNewLayout(with height: CGFloat, for cell: String)
}

class BuildingCell: UITableViewCell {

    var delegate: CellUpdateDelegate!
    var isExpanded = false

}
