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
    //fileprivate var addButton:UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.baseLabsBlue
        layer.cornerRadius = 8
        layer.masksToBounds = true
//        titleLabel = UILabel()
//        titleLabel.text = "Add Group"
//        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
//        titleLabel.textColor = UIColor.white
//        addSubview(titleLabel)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.gsrBtnTitleFont
        titleLabel.textColor = UIColor.white
        titleLabel.text = "Add Group"
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        
        
        _ = titleLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 18, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 22)
//        addButton = UIButton()
//        let attrs = [
//            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .semibold),
//            NSAttributedString.Key.backgroundColor : UIColor(named: "baseLabsBlue"),
//            NSAttributedString.Key.foregroundColor : UIColor.white,
//        ]
//
//        let title = NSAttributedString(string: "Add Group", attributes: attrs as [NSAttributedString.Key : Any])
//        addButton.setAttributedTitle(title, for: UIControl.State.normal)
//        addSubview(addButton)
//        addButton.translatesAutoresizingMaskIntoConstraints = false
//        addButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        addButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
