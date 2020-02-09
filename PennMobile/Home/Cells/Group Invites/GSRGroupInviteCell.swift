//
//  GSRGroupInviteCell.swift
//  PennMobile
//
//  Created by Daniel Salib on 2/8/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit

class GSRGroupInviteCell: UITableViewCell {
    
    static let identifier = "gsrGroupInviteCell"
    static let cellHeight: CGFloat = 107
    
    var invite: GSRGroupInvite! {
        didSet {
            setupCell(with: invite)
        }
    }
    
    fileprivate var groupNameLabel: UILabel!
    fileprivate var groupIcon: GSRGroupIconView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GSRGroupInviteCell {
    fileprivate func setupCell(with invite: GSRGroupInvite) {
        backgroundColor = .clear
        groupNameLabel.text = invite.group
        groupIcon.name = invite.group
        groupIcon.groupColor = GSRGroup.parseColor(color: "College Green")
    }
}

extension GSRGroupInviteCell {
    fileprivate func prepareUI() {
        prepareLabels()
    }
    
    fileprivate func prepareLabels() {
        let padding = UIView.padding
        
        groupNameLabel = getGroupNameLabel()
        groupIcon = getGroupIcon()
        
        addSubview(groupIcon)
        addSubview(groupNameLabel)
        
        groupIcon.translatesAutoresizingMaskIntoConstraints = false
        groupIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding).isActive = true
        groupIcon.topAnchor.constraint(equalTo: topAnchor, constant: padding).isActive = true
        
        groupNameLabel.translatesAutoresizingMaskIntoConstraints = false
        groupNameLabel.leadingAnchor.constraint(equalTo: groupIcon.trailingAnchor, constant: padding).isActive = true
        groupNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding).isActive = true
    }
    
    fileprivate func getGroupIcon() -> GSRGroupIconView {
        let icon = GSRGroupIconView()
        return icon
    }
    
    fileprivate func getGroupNameLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24.0, weight: .regular)
        return label
    }
}
