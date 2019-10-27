//
//  GroupCell.swift
//  PennMobile
//
//  Created by Josh Doman on 4/6/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class GroupCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 120
    static let identifier = "gsrGroupCell"
    
    var group: GSRGroup! {
        didSet {
            setupCell(with: group)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension GroupCell {
    fileprivate func setupCell(with group: GSRGroup) {
        let activeText = group.isActive ? "Active" : "Inactive"
        self.textLabel?.text = "\(group.name) \n\(group.members.count) members\n Status: \(activeText)"
        self.textLabel?.numberOfLines = 3
    }
}

// MARK: - Setup UI
extension GroupCell {
    fileprivate func setupUI() {
    }
}

