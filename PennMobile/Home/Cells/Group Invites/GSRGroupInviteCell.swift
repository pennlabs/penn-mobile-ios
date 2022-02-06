//
//  GSRGroupInviteCell.swift
//  PennMobile
//
//  Created by Daniel Salib on 2/8/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit
protocol GSRGroupInviteCellDelegate {
    func acceptInvite(invite: GSRGroupInvite)
    func declineInvite(invite: GSRGroupInvite)
}

class GSRGroupInviteCell: UITableViewCell {
    
    static let identifier = "gsrGroupInviteCell"
    static let cellHeight: CGFloat = 100
    
    var invite: GSRGroupInvite! {
        didSet {
            setupCell(with: invite)
        }
    }
    
    var delegate: GSRGroupInviteCellDelegate!
    fileprivate var groupNameLabel: UILabel!
    fileprivate var groupIcon: GSRGroupIconView!
    fileprivate var acceptButton: UIButton!
    fileprivate var declineButton: UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GSRGroupInviteCell {
    fileprivate func setupCell(with invite: GSRGroupInvite) {
        backgroundColor = .clear
        groupNameLabel.text = invite.group
        groupIcon.name = invite.group
        groupIcon.groupColor = GSRGroup.parseColor(color: invite.color) ?? UIColor.baseLabsBlue
    }
}

extension GSRGroupInviteCell {
    fileprivate func prepareUI() {
        prepareLabels()
        prepareButtons()
    }
    
    fileprivate func prepareLabels() {
        groupNameLabel = getGroupNameLabel()
        groupIcon = getGroupIcon()
        
        addSubview(groupIcon)
        addSubview(groupNameLabel)
        
        groupIcon.translatesAutoresizingMaskIntoConstraints = false
        groupIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad).isActive = true
        groupIcon.topAnchor.constraint(equalTo: topAnchor, constant: pad).isActive = true
        
        groupNameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(groupIcon.snp.trailing).offset(pad)
            make.trailing.equalTo(snp.trailing).offset(-pad)
            make.top.equalTo(snp.top).offset(pad * 1.5)
        }
    }
    
    fileprivate func prepareButtons() {
        acceptButton = getAcceptButton()
        declineButton = getDeclineButton()
        
        addSubview(acceptButton)
        addSubview(declineButton)
        
        declineButton.snp.makeConstraints { (make) in
            make.leading.equalTo(groupNameLabel.snp.leading)
            make.top.equalTo(groupNameLabel.snp.bottom).offset(pad)
            make.height.equalTo(24)
            make.width.equalTo(94)
        }
        
        acceptButton.snp.makeConstraints { (make) in
            make.leading.equalTo(declineButton.snp.trailing).offset(pad)
            make.top.equalTo(declineButton)
            make.height.equalTo(24)
            make.width.equalTo(94)
        }
    }
    
    fileprivate func getGroupIcon() -> GSRGroupIconView {
        let icon = GSRGroupIconView()
        return icon
    }
    
    fileprivate func getGroupNameLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.numberOfLines = 1
        return label
    }

    private func getAcceptButton() -> UIButton {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(acceptInvite), for: .touchUpInside)
        button.setTitle("Accept", for: .normal)
        button.backgroundColor = .baseBlue
        button.layer.cornerRadius = 4
        button.titleLabel?.font = .secondaryTitleFont
        button.titleLabel?.textColor = .white
        button.tintColor = .white
        button.titleLabel?.textAlignment = .center
        return button
    }
    
    private func getDeclineButton() -> UIButton {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(declineInvite), for: .touchUpInside)
        button.setTitle("Decline", for: .normal)
        button.backgroundColor = .labelTertiary
        button.layer.cornerRadius = 4
        button.titleLabel?.font = .secondaryTitleFont
        button.titleLabel?.textColor = .white
        button.tintColor = .white
        button.titleLabel?.textAlignment = .center
        return button
    }
    
    @objc fileprivate func acceptInvite() {
        delegate.acceptInvite(invite: invite)
    }
    
    @objc fileprivate func declineInvite() {
        delegate.declineInvite(invite: invite)
    }
}
