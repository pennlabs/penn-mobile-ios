//
//  CreateGroupCell.swift
//  PennMobile
//
//  Created by Josh Doman on 4/6/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class CreateGroupCell: UITableViewCell {

    static let cellHeight: CGFloat = 60
    static let identifier = "createGroupCell"

    fileprivate var titleLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLabel = UILabel()
        titleLabel.text = "Add Group"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = UIColor(named: "baseLabsBlue")
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
