//
//  EmptyLaundryCell.swift
//  PennMobile
//
//  Created by Dominic Holmes on 9/30/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

protocol AddLaundryCellDelegate: class {
    func addPressed()
}

class AddLaundryCell: UITableViewCell {
    
    weak var delegate: AddLaundryCellDelegate?
    
    private let mainBackground: UIView = {
        let bg = UIView()
        
        // corner radius
        bg.layer.cornerRadius = 20
        
        // border
        //bg.layer.borderWidth = 0.0
        bg.layer.borderWidth = 1.0
        bg.layer.borderColor = UIColor.lightGray.cgColor
        
        // shadow
        //bg.layer.shadowColor = UIColor.black.cgColor
        bg.layer.shadowColor = UIColor.clear.cgColor
        
        bg.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        bg.layer.shadowOpacity = 0.8
        bg.layer.shadowRadius = 3.0
        bg.backgroundColor = UIColor.whiteGrey
        
        return bg
    }()
    
    private let chooseRoomLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose a Laundry Room"
        label.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        label.textColor = UIColor.darkGray
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var addRoomButton: UIButton = {
        let b = UIButton()
        b.backgroundColor = .clear
        b.contentMode = .scaleAspectFill
        b.clipsToBounds = true
        b.layer.masksToBounds = true
        b.setBackgroundImage(UIImage(named: "AddLaundryRoomButton"), for: .normal)
        b.setBackgroundImage(UIImage(named: "AddLaundryRoomButtonSelected"), for: .selected)
        b.setBackgroundImage(UIImage(named: "AddLaundryRoomButtonSelected"), for: .highlighted)
        b.addTarget(self, action: #selector(addRoom), for: .touchUpInside)
        return b
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(mainBackground)
        
        _ = mainBackground.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                                 topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20,
                                 widthConstant: 0, heightConstant: 0)
        
        mainBackground.addSubview(addRoomButton)
        mainBackground.addSubview(chooseRoomLabel)
        
        addRoomButton.translatesAutoresizingMaskIntoConstraints = false
        
        addRoomButton.heightAnchor.constraint(
            equalTo: mainBackground.heightAnchor,
            multiplier: 0.4).isActive = true
        addRoomButton.widthAnchor.constraint(
            equalTo: mainBackground.heightAnchor,
            multiplier: 0.4).isActive = true
        addRoomButton.centerXAnchor.constraint(
            equalTo: mainBackground.centerXAnchor).isActive = true
        addRoomButton.centerYAnchor.constraint(
            equalTo: mainBackground.centerYAnchor).isActive = true
        
        chooseRoomLabel.translatesAutoresizingMaskIntoConstraints = false
        chooseRoomLabel.centerXAnchor.constraint(
            equalTo: mainBackground.centerXAnchor).isActive = true
        chooseRoomLabel.bottomAnchor.constraint(
            equalTo: addRoomButton.topAnchor,
            constant: -15).isActive = true
    }
    
    @objc private func addRoom() {
        delegate?.addPressed()
    }
}
