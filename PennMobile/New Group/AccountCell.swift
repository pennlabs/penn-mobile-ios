//
//  AccountCell.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 3/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {
    
    var accountImage: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = 30
        imgView.layer.masksToBounds = true
        imgView.clipsToBounds = true
        return imgView
    }()
    
    var accountUsername: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.warmGrey
        label.font = UIFont(name: "HelveticaNeue-Light", size: 19)
        label.textAlignment = .left
        return label
    }()
    
    func setUpView(avatar: UIImage, username: String) {
        accountImage.image = avatar
        accountUsername.text = username
        self.addSubview(accountImage)
        self.addSubview(accountUsername)
        _ = accountImage.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 60)
        _ = accountUsername.anchor(self.topAnchor, left: accountImage.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 30, leftConstant: 15, bottomConstant: 30, rightConstant: 0, widthConstant: 0, heightConstant: 0)
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
