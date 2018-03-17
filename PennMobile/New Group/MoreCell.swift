//
//  MoreCell.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 3/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class MoreCell: UITableViewCell {
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red:0.45, green:0.45, blue:0.45, alpha:1.0)
        label.font = UIFont(name: "HelveticaNeue-Light", size: 19)
        return label
    }()
    
    func setUpView(page: Page) {
        titleLabel.text = page.rawValue
        self.addSubview(titleLabel)
        _ = titleLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 15, leftConstant: 10, bottomConstant: 15, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
