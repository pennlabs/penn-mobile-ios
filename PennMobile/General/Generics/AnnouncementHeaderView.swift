//
//  AnnouncementHeaderView.swift
//  PennMobile
//
//  Created by Josh Doman on 8/26/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

@objc class AnnouncementHeaderView: UITableViewHeaderFooterView {
    
    static let headerHeight: CGFloat = 40
    
    var announcement: String? {
        didSet {
            label.text = announcement
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Light", size: 17)
        label.textColor = UIColor.whiteGrey
        label.textAlignment = .center
        label.numberOfLines = 5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.frenchBlue
        
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
