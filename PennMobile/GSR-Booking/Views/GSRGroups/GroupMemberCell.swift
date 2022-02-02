//
//  GroupMemberCell.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 10/20/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

class GroupMemberCell: UITableViewCell {

    static let identifier = "gsrGroupMemberCell"

    fileprivate var nameLabel: UILabel!
    fileprivate var pennKeyActiveLabel: UILabel!

    var member: GSRGroupMember! {
        didSet {
            setupCell(with: member)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension GroupMemberCell {
    fileprivate func setupCell(with group: GSRGroupMember) {
        if (nameLabel == nil || pennKeyActiveLabel == nil) {
            prepareUI()
        }

        nameLabel.text = "\(member.first) \(member.last) (\(member.pennKey))"
        let pennKeyActive = member.pennKeyActive
        pennKeyActiveLabel.text = pennKeyActive ? "PennID Active" : "PennID Inactive"
        pennKeyActiveLabel.textColor = pennKeyActive ? UIColor(named: "baseGreen") : UIColor(named: "baseRed")
    }
}

// MARK: - Prepare UI
extension GroupMemberCell {
    fileprivate func prepareUI() {
        prepareNameLabel()
        preparePennKeyActiveLabel()
//        backgroundColor = .uiBackgroundSecondary
    }

    fileprivate func prepareNameLabel() {
        nameLabel = UILabel()
        addSubview(nameLabel)

        _ = nameLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 12, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 20)
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    }

    fileprivate func preparePennKeyActiveLabel() {
        pennKeyActiveLabel = UILabel()
        addSubview(pennKeyActiveLabel)

        _ = pennKeyActiveLabel.anchor(nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: bottomAnchor, right: nameLabel.rightAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 12, rightConstant: 0, widthConstant: 0, heightConstant: 15)
        pennKeyActiveLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
    }
}
