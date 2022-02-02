//
//  GroupSettingsCell.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 10/20/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

class GroupSettingsCell: UITableViewCell {

    static let cellHeight: CGFloat = 100
    static let identifier = "gsrGroupSettingsCell"

    fileprivate var titleLabel: UILabel!
    fileprivate var descriptionLabel: UILabel!
    fileprivate var isEnabledSwitch: UISwitch!
    fileprivate var holderView: UIView!

    var delegate: GSRGroupIndividualSettingDelegate?
    var userSetting: GSRGroupIndividualSetting!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCell(with userSetting: GSRGroupIndividualSetting) {
        self.userSetting = userSetting

        if (titleLabel == nil || descriptionLabel == nil || isEnabledSwitch == nil) {
            prepareUI()
        }

        titleLabel.text = userSetting.title
        descriptionLabel.text = userSetting.descr
        isEnabledSwitch.setOn(userSetting.isEnabled, animated: false)
    }

    @objc fileprivate func switchValueChanged() {
        if let delegate = delegate {
            userSetting.isEnabled = isEnabledSwitch.isOn
            delegate.updateSetting(setting: userSetting)
        }
    }
}

// MARK: - Setup UI
extension GroupSettingsCell {

    fileprivate func prepareUI() {
        self.heightAnchor.constraint(equalToConstant: GroupSettingsCell.cellHeight).isActive = true

        prepareHolderView()
        prepareTitleLabel()
        prepareDescriptionLabel()
        prepareIsEnabledSwitch()
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -100).isActive = true
//        backgroundColor = .uiBackgroundSecondary
    }

    fileprivate func prepareHolderView() {
        holderView = UIView()
        addSubview(holderView)
        let inset: CGFloat = 14.0
        _ = holderView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: inset, leftConstant: inset, bottomConstant: inset, rightConstant: inset, widthConstant: 0, heightConstant: 0)
    }

    fileprivate func prepareTitleLabel() {
        titleLabel = UILabel()
        holderView.addSubview(titleLabel)
        _ = titleLabel.anchor(holderView.topAnchor, left: holderView.leftAnchor, bottom: nil, right: holderView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 30)
        titleLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
    }

    fileprivate func prepareDescriptionLabel() {
        descriptionLabel = UILabel()
        holderView.addSubview(descriptionLabel)
        _ = descriptionLabel.anchor(titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: holderView.bottomAnchor, right: titleLabel.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        descriptionLabel.numberOfLines = 3
        descriptionLabel.textColor = UIColor.init(r: 153, g: 153, b: 153)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .light)
    }

    fileprivate func prepareIsEnabledSwitch() {
        isEnabledSwitch = UISwitch()
        holderView.addSubview(isEnabledSwitch)
        _ = isEnabledSwitch.anchor(titleLabel.topAnchor, left: nil, bottom: nil, right: holderView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 51, heightConstant: 0)
        isEnabledSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
}
