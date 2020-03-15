//
//  GroupSubmitBookingButton.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 3/14/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit

class GroupSubmitBookingButton: UIButton {

    fileprivate var submitLabel: UILabel!
    fileprivate var groupNameLabel: UILabel!
    
    var groupName: String! {
        didSet {
            groupNameLabel.text = groupName
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        prepareUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Prepare UI
extension GroupSubmitBookingButton {
    fileprivate func prepareUI() {
        backgroundColor = UIColor.baseLabsBlue
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        prepareSubmitLabel()
        prepareGroupNameLabel()
    }
    
    fileprivate func prepareSubmitLabel() {
        submitLabel = UILabel()
        submitLabel.font = UIFont.gsrBtnTitleFont
        submitLabel.textColor = UIColor.white
        submitLabel.text = "Submit Booking"
        submitLabel.textAlignment = .center
        addSubview(submitLabel)
        
        _ = submitLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 7.5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 22)
    }
    
    fileprivate func prepareGroupNameLabel() {
        groupNameLabel = UILabel()
        groupNameLabel.font = UIFont.gsrBtnSubtitleFont
        groupNameLabel.textColor = UIColor.white
        groupNameLabel.textAlignment = .center
        addSubview(groupNameLabel)
        
        _ = groupNameLabel.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 3, rightConstant: 0, widthConstant: 0, heightConstant: 22)
    }
}
