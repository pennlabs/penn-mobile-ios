//
//  GroupInviteUserCell.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 1/26/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit

class GroupInviteUserCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 60
    static let identifier = "resultsCell"
    
    fileprivate var checkMarkBtn: UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension GroupInviteUserCell {
    fileprivate func setupCell() {
        
    }
}

/*
// MARK: - Setup UI
extension GroupInviteUserCell {
    fileprivate func setupUI() {
        prepareCheckMark()
    }

    fileprivate func prepareCheckMark() {
        checkMarkBtn = UIButton()
        addSubview(checkMarkBtn)
        checkMarkBtn
        checkMarkBtn.translatesAutoresizingMaskIntoConstraints = false
        checkMarkBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        checkMarkBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        checkMarkBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 14).isActive = true
    }
   
}
 */
