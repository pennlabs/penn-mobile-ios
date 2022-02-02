//
//  BuildingHeaderCell.swift
//  PennMobile
//
//  Created by dominic on 6/21/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

enum BuildingHeaderState: String {
    case open = "OPEN"
    case closed = "CLOSED"
    case closedToday = "CLOSED TODAY"
}

class BuildingHeaderCell: BuildingCell {

    static let identifier = "BuildingHeaderCell"
    static let cellHeight: CGFloat = 104

    var building: BuildingHeaderDisplayable! {
        didSet {
            setupCell(with: building)
        }
    }

    fileprivate var buildingTitleLabel : UILabel!
    fileprivate var buildingDescriptionLabel : UILabel!
    fileprivate var buildingHoursLabel : UILabel!

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension BuildingHeaderCell {

    fileprivate func setupCell(with building: BuildingHeaderDisplayable) {
        buildingTitleLabel.text = building.getTitle()
        buildingDescriptionLabel.text = building.getSubtitle()

        let status = building.getStatus()
        buildingHoursLabel.text = status.rawValue
        if status == .open {
            buildingHoursLabel.textColor = .baseYellow
            buildingHoursLabel.font = .primaryInformationFont
        } else {
            buildingHoursLabel.textColor = .labelSecondary
            buildingHoursLabel.font = .secondaryInformationFont
        }
    }
}

// MARK: - Initialize and Prepare UI
extension BuildingHeaderCell {

    fileprivate func prepareUI() {
        buildingTitleLabel = getBuildingTitleLabel()
        buildingDescriptionLabel = getBuildingDescriptionLabel()
        buildingHoursLabel = getBuildingHoursLabel()

        layoutLabels()
    }

    fileprivate func layoutLabels() {
        addSubview(buildingTitleLabel)
        addSubview(buildingDescriptionLabel)
        addSubview(buildingHoursLabel)

        let inset: CGFloat = 14

        _ = buildingDescriptionLabel.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: nil,
            topConstant: 0, leftConstant: inset, bottomConstant: inset, rightConstant: 0, widthConstant: 0, heightConstant: 0)

        _ = buildingTitleLabel.anchor(nil, left: leftAnchor, bottom: buildingDescriptionLabel.topAnchor, right: nil,
            topConstant: 0, leftConstant: inset, bottomConstant: inset, rightConstant: 0, widthConstant: 0, heightConstant: 0)

        _ = buildingHoursLabel.anchor(nil, left: nil, bottom: nil, right: rightAnchor,
            topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: inset, widthConstant: 0, heightConstant: 0)
        buildingHoursLabel.centerYAnchor.constraint(equalTo: buildingDescriptionLabel.centerYAnchor).isActive = true
    }

    fileprivate func getBuildingTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        return label
    }

    fileprivate func getBuildingDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryInformationFont
        label.textColor = .labelSecondary
        label.textAlignment = .left
        return label
    }

    fileprivate func getBuildingHoursLabel() -> UILabel{
        let label = UILabel()
        label.font = .secondaryInformationFont
        label.textColor = .baseYellow
        label.textAlignment = .right
        return label
    }
}

