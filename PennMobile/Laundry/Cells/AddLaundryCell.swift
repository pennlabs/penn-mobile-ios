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
    
    var numberOfRoomsSelected: Int = 0 {
        didSet {
            if numberOfRoomsSelected > 0 {
                chooseRoomLabel.text = "\(numberOfRoomsSelected) of 3 rooms selected"
            } else {
                chooseRoomLabel.text = "No laundry rooms selected"
            }
        }
    }
    
    private let mainBackground: UIView = {
        let bg = UIView()
        
        // corner radius for cell
        bg.layer.cornerRadius = 15.0
        
        // border
        //bg.layer.borderWidth = 0.0
        bg.layer.borderWidth = 1.0
        bg.layer.borderColor = UIColor.clear.cgColor
        
        // shadow
        bg.layer.shadowColor = UIColor.clear.cgColor
        //bg.layer.shadowColor = UIColor.clear.cgColor
        
        bg.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        bg.layer.shadowOpacity = 0.25
        bg.layer.shadowRadius = 4.0
        bg.backgroundColor = UIColor.clear
        
        return bg
    }()
    
    private let chooseRoomLabel: UILabel = {
        let label = UILabel()
        label.text = "0 of 3 rooms selected"
        label.font = .secondaryInformationFont
        label.textColor = .secondaryInformationGrey
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var addRoomButton: UIButton = {
        let b = UIButton()
        b.setTitleColor(UIColor(red: 0.161, green: 0.502, blue: 0.725, alpha: 1.0),
                        for: .normal)
        b.setTitleColor(UIColor(red: 0.161, green: 0.502, blue: 0.725, alpha: 0.3),
                        for: UIControlState.highlighted)
        b.setTitle("Select a room", for: .normal)
        b.titleLabel?.font = UIFont.primaryInformationFont
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
                                  topConstant: 12, leftConstant: 17, bottomConstant: 12, rightConstant: 17,
                                  widthConstant: 0, heightConstant: 0)
        
        mainBackground.addSubview(addRoomButton)
        mainBackground.addSubview(chooseRoomLabel)
        
        chooseRoomLabel.translatesAutoresizingMaskIntoConstraints = false
        chooseRoomLabel.topAnchor.constraint(
            equalTo: mainBackground.topAnchor,
            constant: 20.0).isActive = true
        chooseRoomLabel.centerXAnchor.constraint(
            equalTo: mainBackground.centerXAnchor).isActive = true
        
        addRoomButton.translatesAutoresizingMaskIntoConstraints = false
        addRoomButton.topAnchor.constraint(
            equalTo: chooseRoomLabel.bottomAnchor,
            constant: 0.0).isActive = true
        addRoomButton.centerXAnchor.constraint(
            equalTo: chooseRoomLabel.centerXAnchor).isActive = true
        
    }
    
    @objc private func addRoom() {
        delegate?.addPressed()
    }
}
