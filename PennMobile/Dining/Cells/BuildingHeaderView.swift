//
//  BuildingHeaderView.swift
//  PennMobile
//
//  Created by Dominic Holmes on 6/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class BuildingHeaderView: UITableViewHeaderFooterView {
    
    static let headerHeight: CGFloat = 134
    static let identifier = "BuildingHeaderView"
    
    var buildingTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .primaryTitleGrey
        label.textAlignment = .left
        return label
    }()

    var buildingDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .primaryTitleGrey
        label.textAlignment = .left
        return label
    }()

    var buildingHoursLabel: UILabel = {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .primaryTitleGrey
        label.textAlignment = .left
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .green
        
        addSubview(buildingTitleLabel)
        _ = buildingTitleLabel.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 28, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 0)

        buildingTitleLabel.text = "Test Building"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

