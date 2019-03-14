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
    
    var iconImage: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    func setUpView(with title: String) {
        titleLabel.text = title
        self.addSubview(titleLabel)
        _ = titleLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 12, leftConstant: 15, bottomConstant: 12, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    func setUpView(with page: Page, icon: UIImage) {
        iconImage.image = icon
        titleLabel.text = page.rawValue
        self.addSubview(iconImage)
        self.addSubview(titleLabel)
        _ = iconImage.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, topConstant: 15, leftConstant: 15, bottomConstant: 15, rightConstant: 0, widthConstant: 20, heightConstant: 0)
        _ = titleLabel.anchor(self.topAnchor, left: iconImage.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 12, leftConstant: 10, bottomConstant: 12, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorHeight = CGFloat(2)
        let customSeparator = UIView(frame: CGRect(x: 0, y: frame.size.height + 3 + separatorHeight, width: UIScreen.main.bounds.width, height: separatorHeight))
        customSeparator.backgroundColor = UIColor(red:0.96, green:0.97, blue:0.97, alpha:1.0)
        addSubview(customSeparator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
