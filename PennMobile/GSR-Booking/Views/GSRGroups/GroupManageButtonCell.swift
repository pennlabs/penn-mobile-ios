//
//  GroupManageButtonCell.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 11/22/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit


class GroupManageButtonCell: UITableViewCell {

    static let identifier = "gsrGroupManageButtonCell"
    let buttonInset: CGFloat = 14.0

    fileprivate var bookGroupBtn: UIButton!
    fileprivate var inviteGroupBtn: UIButton!
    fileprivate var leaveGroupBtn: UIButton!
    
    var delegate: GroupManageButtonDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Prepare UI
extension GroupManageButtonCell {
    func prepareUI() {
        prepareBookGroupBtn()
        prepareShareGroupBtn()
        prepareLeaveGroupBtn()
        backgroundColor = .uiGroupedBackground
    }
    
    fileprivate func prepareBookGroupBtn() {
        bookGroupBtn = UIButton()
        bookGroupBtn.setTitle("Book with Group", for: .normal)
        bookGroupBtn.backgroundColor = .uiGroupedBackgroundSecondary
        bookGroupBtn.setTitleColor(.baseLabsBlue, for: .normal)
        bookGroupBtn.addTarget(self, action: #selector(bookGroupBtnTapped), for: .touchUpInside)
        bookGroupBtn.layer.cornerRadius = 8
        bookGroupBtn.layer.masksToBounds = true
        
        addSubview(bookGroupBtn)
        _ = bookGroupBtn.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: buttonInset, leftConstant: buttonInset, bottomConstant: 0, rightConstant: buttonInset, widthConstant: 0, heightConstant: 50)
    }
    
    fileprivate func prepareShareGroupBtn() {
        inviteGroupBtn = UIButton()
        inviteGroupBtn.setTitle("Invite to Group", for: .normal)
        inviteGroupBtn.backgroundColor = .uiGroupedBackgroundSecondary
        inviteGroupBtn.setTitleColor(.baseLabsBlue, for: .normal)
        inviteGroupBtn.addTarget(self, action: #selector(shareGroupBtnTapped), for: .touchUpInside)
        inviteGroupBtn.layer.cornerRadius = 8
        inviteGroupBtn.layer.masksToBounds = true
        
        addSubview(inviteGroupBtn)
        _ = inviteGroupBtn.anchor(bookGroupBtn.bottomAnchor, left: bookGroupBtn.leftAnchor, bottom: nil, right: bookGroupBtn.rightAnchor, topConstant: buttonInset, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
    }
    
    fileprivate func prepareLeaveGroupBtn() {
        leaveGroupBtn = UIButton()
        leaveGroupBtn.setTitle("Leave Group", for: .normal)
        leaveGroupBtn.backgroundColor = .uiGroupedBackgroundSecondary
        leaveGroupBtn.setTitleColor(.baseRed, for: .normal)
        leaveGroupBtn.addTarget(self, action: #selector(leaveGroupBtnTapped), for: .touchUpInside)
        leaveGroupBtn.layer.cornerRadius = 8
        leaveGroupBtn.layer.masksToBounds = true
        
        addSubview(leaveGroupBtn)
        _ = leaveGroupBtn.anchor(inviteGroupBtn.bottomAnchor, left: bookGroupBtn.leftAnchor, bottom: bottomAnchor, right: bookGroupBtn.rightAnchor, topConstant: buttonInset, leftConstant: 0, bottomConstant: buttonInset, rightConstant: 0, widthConstant: 0, heightConstant: 50)
    }
    
}

extension GroupManageButtonCell {
    @objc func bookGroupBtnTapped() {
        if let delegate = delegate {
            delegate.bookGroup()
        }
    }
    
    @objc func shareGroupBtnTapped() {
        if let delegate = delegate {
            delegate.inviteGroup()
        }
    }
    
    @objc func leaveGroupBtnTapped() {
        if let delegate = delegate {
            delegate.leaveGroup()
        }
    }
}
