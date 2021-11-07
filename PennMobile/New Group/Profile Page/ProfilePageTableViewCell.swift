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
    }
    
    fileprivate func prepareKeyLabel() {
        self.contentView.addSubview(keyLabel)
        keyLabel.numberOfLines = 1
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10.0).isActive = true
        keyLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10.0).isActive = true
        keyLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        keyLabel.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.35).isActive = true
    }
    
    fileprivate func prepareInfoLabel() {
        self.contentView.addSubview(infoLabel)
        infoLabel.textAlignment = .right
        infoLabel.numberOfLines = 0
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10.0).isActive = true
        infoLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10.0).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20.0).isActive = true
        infoLabel.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.65).isActive = true
    }
    
}
