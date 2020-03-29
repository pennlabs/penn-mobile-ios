//
//  CreateGroupCell.swift
//  PennMobile
//
//  Created by Josh Doman on 4/6/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class CreateGroupCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 60
    static let identifier = "createGroupCell"
    
    fileprivate var titleLabel: UILabel!
    fileprivate var addButton:UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let bgView = UIView()
        bgView.layer.cornerRadius = 8
        bgView.backgroundColor = UIColor(named:"baseLabsBlue")


        addSubview(bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        _ = bgView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 8, leftConstant: 15, bottomConstant: 8, rightConstant: 15)

        titleLabel = UILabel()
        titleLabel.text = "Create a New Group"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = UIColor.white
        bgView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
