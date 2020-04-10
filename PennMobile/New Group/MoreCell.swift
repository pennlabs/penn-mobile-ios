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
        label.textColor = .labelPrimary
        label.font = UIFont(name: "HelveticaNeue-Light", size: 19)
        return label
    }()
    
    var iconImage: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 7
        iv.clipsToBounds = true
        return iv
    }()
    
    func setUpView(with title: String) {
        iconImage.image = nil
        titleLabel.text = title
        self.addSubview(titleLabel)
        _ = titleLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 12, leftConstant: 15, bottomConstant: 12, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    func setUpView(with page: Feature, icon: UIImage) {
        iconImage.image = icon
        titleLabel.text = page.rawValue
        self.addSubview(iconImage)
        self.addSubview(titleLabel)
        _ = iconImage.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, topConstant: 10, leftConstant: 15, bottomConstant: 10, rightConstant: 0, widthConstant: 30, heightConstant: 0)
        _ = titleLabel.anchor(self.topAnchor, left: iconImage.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 12, leftConstant: 10, bottomConstant: 12, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
