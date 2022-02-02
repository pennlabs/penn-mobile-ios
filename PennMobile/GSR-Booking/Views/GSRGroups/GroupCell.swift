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

    fileprivate var groupIcon: GSRGroupIconView!
    fileprivate var groupName: UILabel!
    fileprivate var activeLabel: UILabel!

    var group: GSRGroup! {
        didSet {
            setupCell()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension GroupCell {
    fileprivate func setupCell() {
        // refactor!
        if groupIcon == nil || groupName == nil || activeLabel == nil {
            setupUI()
        } else {
            groupIcon.backgroundColor = group.color
            groupIcon.name = group.name
            groupName.text = group.name
            if let userSettings = group.userSettings {
                let text = userSettings.pennKeyActive.isEnabled ? "PennID Active" : "PennID Inactive"
                activeLabel.text = text
                activeLabel.textColor = userSettings.pennKeyActive.isEnabled ? UIColor(named: "baseGreen") : UIColor(named: "baseRed")
            }
        }
    }
}

// MARK: - Setup UI
extension GroupCell {
    fileprivate func setupUI() {
        prepareGroupIcon()
        prepareGroupNameLabel()
        prepareActiveLabel()
    }

    fileprivate func prepareGroupIcon() {
        groupIcon = GSRGroupIconView()
        addSubview(groupIcon)
        groupIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true
        groupIcon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    fileprivate func prepareGroupNameLabel() {
        groupName = UILabel()
        groupName.font = UIFont.systemFont(ofSize: 24.0, weight: .regular)
        addSubview(groupName)
        groupName.translatesAutoresizingMaskIntoConstraints = false
        groupName.leadingAnchor.constraint(equalTo: groupIcon.trailingAnchor, constant: 14).isActive = true
        groupName.topAnchor.constraint(equalTo: groupIcon.topAnchor, constant: 4).isActive = true
    }

    fileprivate func prepareActiveLabel() {
        activeLabel = UILabel()
        addSubview(activeLabel)
        activeLabel.translatesAutoresizingMaskIntoConstraints = false
        activeLabel.leadingAnchor.constraint(equalTo: groupName.leadingAnchor).isActive = true
        activeLabel.topAnchor.constraint(equalTo: groupName.bottomAnchor, constant: 5 ).isActive = true

    }
}
