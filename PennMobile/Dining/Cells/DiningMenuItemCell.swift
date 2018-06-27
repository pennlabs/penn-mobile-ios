//
//  DiningMenuItemCell.swift
//  PennMobile
//
//  Created by dominic on 6/26/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class DiningMenuItemCell: UITableViewCell {
    
    static let identifier = "DiningMenuItemCell"
    static let cellHeight: CGFloat = 45
    
    var menuItem: DiningMenuItem! {
        didSet {
            setupCell(with: menuItem)
        }
    }
    
    // MARK: - UI Elements
    fileprivate var nameLabel: UILabel!
    
    // MARK: - Init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension DiningMenuItemCell {
    fileprivate func setupCell(with item: DiningMenuItem) {
        nameLabel.text = item.name
    }
}

// MARK: - Initialize and Layout UI Elements
extension DiningMenuItemCell {
    
    fileprivate func prepareUI() {
        prepareLabels()
    }
    
    // MARK: Labels
    fileprivate func prepareLabels() {
        nameLabel = getNameLabel()
        addSubview(nameLabel)
        
        _ = nameLabel.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, leftConstant: 30)
    }
}

// MARK: - Define UI Elements
extension DiningMenuItemCell {
    fileprivate func getNameLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = .primaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shrinkUntilFits()
        return label
    }
}
