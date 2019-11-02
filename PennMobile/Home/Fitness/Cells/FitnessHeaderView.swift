//
//  FitnessHeaderView.swift
//  PennMobile
//
//  Created by Dominic Holmes on 9/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class FitnessHeaderView: UITableViewHeaderFooterView {
    
    static let headerHeight: CGFloat = 60
    static let identifier = "fitnessHeaderView"
    
    var label: UILabel = {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .uiBackground
        
        addSubview(label)
        _ = label.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 28, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
