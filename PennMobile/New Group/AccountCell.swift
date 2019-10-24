//
//  AccountCell.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 3/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

//protocol AccountCellDelegate {
//    func handleLogout()
//}

class AccountCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 100
    
    var student: Student! {
        didSet {
            nameLabel.text = "\(student.first) \(student.last)"
            if let imageUrl = student.imageUrl {
                ImageNetworkingManager.instance.downloadImage(imageUrl: imageUrl) { (image) in
                    self.accountImageView.image = image
                }
            } else {
                accountImageView.image = UIImage(named: "Franklin")
            }
        }
    }
    
//    var delegate: AccountCellDelegate!
    
    fileprivate var accountImageView: UIImageView!
    fileprivate var nameLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Prepare UI
extension AccountCell {
    fileprivate func prepareUI() {
        prepareImageView()
//        prepareLogoutButton()
        prepareUsername()
    }
    
    private func prepareImageView() {
        accountImageView = UIImageView()
        accountImageView.layer.cornerRadius = 40
        accountImageView.clipsToBounds = true
        accountImageView.contentMode = .scaleAspectFill
        
        self.addSubview(accountImageView)
        _ = accountImageView.anchor(nil, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 80, heightConstant: 80)
        accountImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func prepareUsername() {
        nameLabel = UILabel()
        nameLabel.textColor = UIColor.labelSecondary
        nameLabel.font = UIFont(name: "HelveticaNeue-Light", size: 19)
        nameLabel.textAlignment = .left
        nameLabel.numberOfLines = 3
        
        self.addSubview(nameLabel)
        _ = nameLabel.anchor(nil, left: accountImageView.rightAnchor, bottom: self.bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
