//
//  ProfilePageTableViewCell.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 9/29/21.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import UIKit

class ProfilePageTableViewCell: UITableViewCell {
    static let identifier = "profileCell"
    var key: String! {
        didSet {
            keyLabel.text = key
        }
    }
    var info: String! {
        didSet {
            infoLabel.text = info
        }
    }
    fileprivate var keyLabel = UILabel()
    fileprivate var infoLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func prepareUI() {
        backgroundColor = .uiGroupedBackgroundSecondary
        prepareKeyLabel()
        prepareInfoLabel()
        self.heightAnchor.constraint(equalTo: infoLabel.heightAnchor, constant: 20).isActive = true
    }
    
    fileprivate func prepareKeyLabel() {
        self.contentView.addSubview(keyLabel)
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        keyLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        keyLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    fileprivate func prepareInfoLabel() {
        self.contentView.addSubview(infoLabel)
        infoLabel.textAlignment = .right
        infoLabel.numberOfLines = 0
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20.0).isActive = true
        infoLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.65).isActive = true
    }
    
}
