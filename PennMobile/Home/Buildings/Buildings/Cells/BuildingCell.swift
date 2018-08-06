//
//  BuildingCell.swift
//  PennMobile
//
//  Created by dominic on 6/21/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

protocol CellUpdateDelegate: class {
    func cellRequiresNewLayout(with height: CGFloat, for cell: String)
}

class BuildingCell: UITableViewCell {
    
    var venue: DiningVenue!
    var delegate: CellUpdateDelegate!
    var isExpanded = false
}
