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
    
    var settings: GSRGroupIndividualSettings! {
        didSet {
            setupCell(with: settings)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension GroupSettingsCell {
    fileprivate func setupCell(with setting: GSRGroupIndividualSettings) {
        textLabel?.numberOfLines = 2
        textLabel?.text = "notifications: \(setting.notificationsOn)\nactive: \(setting.pennKeyActive)"
    }
}
