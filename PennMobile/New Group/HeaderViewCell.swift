//
//  HeaderViewCell.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 3/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class HeaderViewCell: UITableViewCell {
    
    var headerLabel: UILabel = {
        let headerLabel = UILabel()
        headerLabel.textColor = .labelSecondary
        headerLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        return headerLabel
    }()
    
    func setUpView(title: String) {
        self.backgroundColor = .uiGroupedBackground
        headerLabel.text = title
        self.addSubview(headerLabel)
        
        _ = headerLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 0)
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
