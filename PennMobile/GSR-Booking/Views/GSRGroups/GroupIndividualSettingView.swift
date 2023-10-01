//
//  GroupIndividualSettingView.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 11/8/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit
import PennSharedCode

class GroupIndividualSettingView: UIView {

    fileprivate var titleLabel: UILabel!
    fileprivate var descriptionLabel: UILabel!
    fileprivate var isEnabledSwitch: UISwitch!

    init(title: String, description: String, isEnabled: Bool) {
        super.init(frame: CGRect.zero)

        prepareUI(title, description, isEnabled)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: Setup UI
extension GroupIndividualSettingView {
    fileprivate func prepareUI(_ title: String, _ description: String, _ isEnabled: Bool) {
        prepareTitleLabel()
        prepareDescriptionLabel()
        prepareIsEnabledSwitch()
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -100).isActive = true

        titleLabel.text = title
        descriptionLabel.text = description
        isEnabledSwitch.setOn(isEnabled, animated: true)
    }

    fileprivate func prepareTitleLabel() {
        titleLabel = UILabel()
        addSubview(titleLabel)
        _ = titleLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 30)
        titleLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
    }

    fileprivate func prepareDescriptionLabel() {
        descriptionLabel = UILabel()
        addSubview(descriptionLabel)
        _ = descriptionLabel.anchor(titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: bottomAnchor, right: titleLabel.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        descriptionLabel.numberOfLines = 3
        descriptionLabel.textColor = UIColor.init(r: 153, g: 153, b: 153)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .light)
    }

    fileprivate func prepareIsEnabledSwitch() {
        isEnabledSwitch = UISwitch()
        addSubview(isEnabledSwitch)
        _ = isEnabledSwitch.anchor(titleLabel.topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 51, heightConstant: 0)
    }
}
