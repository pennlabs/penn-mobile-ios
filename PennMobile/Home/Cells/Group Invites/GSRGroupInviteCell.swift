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
    
    fileprivate var groupLabel: UILabel!
    
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
        print(invite.group)
        backgroundColor = .clear
        groupLabel.text = invite.group
    }
}

extension GSRGroupInviteCell {
    fileprivate func prepareUI() {
        prepareLabels()
        prepareGroupLogo()
    }
    
    fileprivate func prepareLabels() {
        let padding = UIView.padding
        
        groupLabel = getGroupLabel()
        
        addSubview(groupLabel)
        
        _ = groupLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 13, leftConstant: 25)
    }
    
    fileprivate func prepareGroupLogo() {
        
    }
    
    fileprivate func getGroupLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 18)
        label.textAlignment = .center
        label.textColor = UIColor.labelPrimary
        label.numberOfLines = 2
        return label
    }
}
