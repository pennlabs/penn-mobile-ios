//
//  GroupMemberCell.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 10/20/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

class GroupMemberCell: UITableViewCell {

    static let cellHeight: CGFloat = 120
    static let identifier = "gsrGroupMemberCell"
    
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
        self.textLabel?.text = "\(member.first) \(member.last)"
    }
}
