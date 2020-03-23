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
        
        groupNameLabel.translatesAutoresizingMaskIntoConstraints = false
        groupNameLabel.leadingAnchor.constraint(equalTo: groupIcon.trailingAnchor, constant: pad).isActive = true
        groupNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad).isActive = true
        groupNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: pad).isActive = true
    }
    
    fileprivate func prepareButtons() {
        acceptButton = getAcceptButton()
        declineButton = getDeclineButton()
        
        addSubview(acceptButton)
        addSubview(declineButton)
        
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        declineButton.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.leadingAnchor.constraint(equalTo: groupNameLabel.leadingAnchor).isActive = true
        acceptButton.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 10).isActive = true
        acceptButton.widthAnchor.constraint(equalTo: declineButton.widthAnchor).isActive = true
        
        declineButton.leadingAnchor.constraint(equalTo: acceptButton.trailingAnchor, constant: pad).isActive = true
        declineButton.trailingAnchor.constraint(equalTo: groupNameLabel.trailingAnchor, constant: -50).isActive = true
        declineButton.topAnchor.constraint(equalTo: acceptButton.topAnchor).isActive = true
    }
    
    fileprivate func getGroupIcon() -> GSRGroupIconView {
        let icon = GSRGroupIconView()
        return icon
    }
    
    fileprivate func getGroupNameLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24.0, weight: .regular)
        label.numberOfLines = 1
        return label
    }
    
    fileprivate func getAcceptButton() -> UIButton {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(acceptInvite), for: .touchUpInside)
        button.setTitle("Accept", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.baseBlue
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }
    
    fileprivate func getDeclineButton() -> UIButton {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(declineInvite), for: .touchUpInside)
        button.setTitle("Decline", for: .normal)
        button.setTitleColor(UIColor.labelPrimary, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.labelPrimary.cgColor
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }
    
    @objc fileprivate func acceptInvite() {
        delegate.acceptInvite(invite: invite)
    }
    
    @objc fileprivate func declineInvite() {
        delegate.declineInvite(invite: invite)
    }
}
