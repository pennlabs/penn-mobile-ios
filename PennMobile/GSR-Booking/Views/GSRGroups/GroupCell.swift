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
    
    fileprivate var groupImage: UIImageView!
    fileprivate var groupName: UILabel!
    fileprivate var activeLabel: UILabel!
    
    var group: GSRGroup! {
        didSet {
            setupCell(with: group)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
//        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension GroupCell {
    fileprivate func setupCell(with group: GSRGroup) {
//        let activeText = group.isActive ? "Active" : "Inactive"
//        self.textLabel?.text = "\(group.name)\n Status: \(activeText)"
//        self.textLabel?.numberOfLines = 3
        setupUI()
    }
}

// MARK: - Setup UI
extension GroupCell {
    fileprivate func setupUI() {
        prepareGroupImageView()
        prepareGroupNameLabel()
        prepareActiveLabel()
    }
    
    fileprivate func prepareGroupImageView() {
        groupImage = UIImageView()
        addSubview(groupImage)
        groupImage.translatesAutoresizingMaskIntoConstraints = false
        groupImage.heightAnchor.constraint(equalToConstant: 70).isActive = true
        groupImage.widthAnchor.constraint(equalToConstant: 70).isActive = true
        groupImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true
        groupImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        groupImage.layer.cornerRadius = 35
        groupImage.layer.masksToBounds = true
        groupImage.backgroundColor = UIColor(named: "blueLighter")
        groupImage.contentMode = .scaleAspectFit
    }
    
    fileprivate func prepareGroupNameLabel() {
        groupName = UILabel()
        groupName.text = group.name
        groupName.font = UIFont.systemFont(ofSize: 24.0, weight: .regular)
        addSubview(groupName)
        groupName.translatesAutoresizingMaskIntoConstraints = false
        groupName.leadingAnchor.constraint(equalTo: groupImage.trailingAnchor, constant: 14).isActive = true
        groupName.topAnchor.constraint(equalTo: groupImage.topAnchor, constant: 4).isActive = true
    }
    
    fileprivate func prepareActiveLabel() {
        activeLabel = UILabel()
        addSubview(activeLabel)
        activeLabel.translatesAutoresizingMaskIntoConstraints = false
        activeLabel.leadingAnchor.constraint(equalTo: groupName.leadingAnchor).isActive = true
        activeLabel.topAnchor.constraint(equalTo: groupName.bottomAnchor, constant: 5 ).isActive = true
        let text = group.isActive ? "PennID Active" : "PennID Inactive"
        activeLabel.text = text
        activeLabel.textColor = group.isActive ? UIColor(named: "baseGreen") : UIColor(named: "baseRed")
    }
}

