//
//  NotificationsTableViewCell.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    static let identifier = "notificationCell"

    weak var delegate: NotificationViewControllerChangedPreference!

    fileprivate var option: NotificationOption!
    fileprivate var label: UILabel!
    fileprivate var optionSwitch: UISwitch!

    fileprivate var buildingImageLeftConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.prepareUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(with option: NotificationOption, isEnabled: Bool) {
        self.option = option
        self.label.text = option.cellTitle
        self.optionSwitch.setOn(isEnabled, animated: false)
    }
}

// MARK: - Prepare UI
extension NotificationTableViewCell {

    @objc func didToggle(_ sender: UISwitch) {
        if delegate.allowChange() {
            delegate.changed(option: option, toValue: sender.isOn)
        } else {
            delegate.requestChange(option: option, toValue: sender.isOn)
        }
    }

    fileprivate func prepareUI() {
        prepareSwitch()
        prepareLabel()
    }

    fileprivate func prepareSwitch() {
        optionSwitch = UISwitch()
        optionSwitch.tintColor = UIColor.purpleLight
        optionSwitch.translatesAutoresizingMaskIntoConstraints = false
        addSubview(optionSwitch)

        optionSwitch.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        optionSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14).isActive = true

        optionSwitch.addTarget(self, action: #selector(didToggle(_:)), for: .primaryActionTriggered)
    }

    fileprivate func prepareLabel() {
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14.0).isActive = true
        label.widthAnchor.constraint(equalTo: widthAnchor, constant: -90.0).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 7.0).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7.0).isActive = true

        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
    }
}
