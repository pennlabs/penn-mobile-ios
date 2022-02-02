//
//  GroupHeaderCell.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 11/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit
import Kingfisher

class GroupHeaderCell: UITableViewCell {

    static let identifier = "gsrGroupHeaderCell"
    fileprivate var groupIcon: GSRGroupIconView!
    fileprivate var titleLabel: UILabel!
    fileprivate var memberCountLabel: UILabel!

    fileprivate let inset : CGFloat = 14.0

    var groupColor: UIColor! {
        didSet {
            groupIcon.groupColor = groupColor
        }
    }

    var groupTitle: String! {
        didSet {
            titleLabel.text = "\(groupTitle!)"
            groupIcon.name = groupTitle
        }
    }

    var memberCount: Int! {
        didSet {
            memberCountLabel.text = "\(memberCount!) MEMBERS"
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - UI
extension GroupHeaderCell {
    fileprivate func prepareUI() {
        prepareGroupIcon()
        prepareTitle()
        prepareMemberCountLabel()
        backgroundColor = .uiGroupedBackground
    }

    fileprivate func prepareGroupIcon() {
        let height : CGFloat = 63.0
        groupIcon = GSRGroupIconView()
        groupIcon.layer.cornerRadius = height / 2.0 //half of height
        groupIcon.layer.masksToBounds = true
        addSubview(groupIcon)
        _ = groupIcon.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 26.0, leftConstant: inset, bottomConstant: 26.0, rightConstant: 0, widthConstant: height, heightConstant: height)
    }

    fileprivate func prepareTitle() {
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 24.0, weight: .bold)

        addSubview(titleLabel)
        _ = titleLabel.anchor(nil, left: groupIcon.rightAnchor, bottom: groupIcon.bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 14.0, bottomConstant: 7.5, rightConstant: inset, widthConstant: 0, heightConstant: 30)
    }

    fileprivate func prepareMemberCountLabel() {
        memberCountLabel = UILabel()
        memberCountLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
        memberCountLabel.textColor = UIColor.init(r: 153, g: 153, b: 153)

        addSubview(memberCountLabel)
        _ = memberCountLabel.anchor(nil, left: titleLabel.leftAnchor, bottom: titleLabel.topAnchor, right: titleLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 1, rightConstant: 0, widthConstant: 0, heightConstant: 14.0)
    }

}
