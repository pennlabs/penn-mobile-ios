//
//  BuildingSectionHeader.swift
//  PennMobile
//
//  Created by dominic on 7/14/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class BuildingSectionHeader: UITableViewHeaderFooterView {
    
    static let headerHeight: CGFloat = 25
    
    var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.primaryTitleFont.withSize(18.0)
        label.textColor = .labelPrimary
        label.textAlignment = .left
        label.text = ""
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        
        addSubview(label)
        _ = label.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 14, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
