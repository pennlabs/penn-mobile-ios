//
//  LinkCell.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 4/22/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class LinkCell: UITableViewCell {
    
    var linkLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red:0.45, green:0.45, blue:0.45, alpha:1.0)
        label.font = UIFont(name: "HelveticaNeue-Light", size: 19)
        return label
    }()
    
    func setUpView(link: Link) {
        linkLabel.text = link.name
        addSubview(linkLabel)
        _ = linkLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 15, leftConstant: 15, bottomConstant: 15, rightConstant: 50, widthConstant: 0, heightConstant: 0)
    }
}
