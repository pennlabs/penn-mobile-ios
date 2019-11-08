//
//  GroupSettingsCell.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 10/20/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

class GroupSettingsCell: UITableViewCell {

    static let cellHeight: CGFloat = 120
    static let identifier = "gsrGroupSettingsCell"
    
    fileprivate var pennKeySettingView: GroupIndividualSettingView!
    fileprivate var notificationSettingView: GroupIndividualSettingView!
    
    var settings: GSRGroupIndividualSettings! {
        didSet {
            setupCell(with: settings)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension GroupSettingsCell {
    fileprivate func setupCell(with setting: GSRGroupIndividualSettings) {
//        textLabel?.numberOfLines = 2
//        textLabel?.text = "notifications: \(setting.notificationsOn)\nactive: \(setting.pennKeyActive)"
        setupUI()
    }
    
   
}

//MARK: - Setup UI
extension GroupSettingsCell {
    fileprivate func setupUI() {
        preparePennKeySettingView()
        prepareNotificationSettingView()
    }
    
    fileprivate func preparePennKeySettingView() {
        pennKeySettingView = GroupIndividualSettingView(title: "PennKey Permission", description: "Anyone in this group can book a study room block using your PennKey.", isEnabled: false)
        addSubview(pennKeySettingView)
        let inset: CGFloat = 14.0
        _ = pennKeySettingView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: inset, leftConstant: inset, bottomConstant: 0, rightConstant: inset, widthConstant: 0, heightConstant: 75)
    }
    
    fileprivate func prepareNotificationSettingView() {
        notificationSettingView = GroupIndividualSettingView(title: "Notifications", description: "You’ll receive a notification any time a room is booked by this group.", isEnabled: false)
        addSubview(notificationSettingView)
        let inset: CGFloat = 14.0
        _ = notificationSettingView.anchor(pennKeySettingView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: inset, leftConstant: inset, bottomConstant: inset, rightConstant: inset, widthConstant: 0, heightConstant: 75)
    }

}


