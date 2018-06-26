//
//  BuildingHoursCell.swift
//  PennMobile
//
//  Created by dominic on 6/25/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class BuildingHoursCell: BuildingCell {
    
    static let identifier = "BuildingHoursCell"
    static let cellHeight: CGFloat = 188
    
    override var venue: DiningVenue! {
        didSet {
            setupCell(with: venue)
        }
    }
    
    fileprivate var buildingTitleLabel : UILabel!
    fileprivate var buildingDescriptionLabel : UILabel!
    fileprivate var buildingHoursLabel : UILabel!
    
    // MARK: - Init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension BuildingHoursCell {
    
    fileprivate func setupCell(with venue: DiningVenue) {
        buildingTitleLabel.text = DiningVenueName.getVenueName(for: venue.name)
        buildingDescriptionLabel.text = "Campus Dining Hall"
        
        if venue.times != nil, venue.times!.isEmpty {
            buildingHoursLabel.text = "CLOSED TODAY"
            buildingHoursLabel.textColor = .secondaryInformationGrey
            buildingHoursLabel.font = .secondaryInformationFont
        } else if venue.times != nil && venue.times!.isOpen {
            buildingHoursLabel.text = "OPEN"
            buildingHoursLabel.textColor = .informationYellow
            buildingHoursLabel.font = .primaryInformationFont
        } else {
            buildingHoursLabel.text = "CLOSED"
            buildingHoursLabel.textColor = .secondaryInformationGrey
            buildingHoursLabel.font = .secondaryInformationFont
        }
    }
}

// MARK: - Initialize and Prepare UI
extension BuildingHoursCell {
    
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
        
        let inset: CGFloat = 28
        
        _ = buildingDescriptionLabel.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: nil,
                                            topConstant: 0, leftConstant: inset, bottomConstant: inset, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        _ = buildingTitleLabel.anchor(nil, left: leftAnchor, bottom: buildingDescriptionLabel.topAnchor, right: nil,
                                      topConstant: 0, leftConstant: inset, bottomConstant: inset, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        _ = buildingHoursLabel.anchor(nil, left: nil, bottom: bottomAnchor, right: rightAnchor,
                                      topConstant: 0, leftConstant: 0, bottomConstant: inset, rightConstant: inset, widthConstant: 0, heightConstant: 0)
    }
    
    fileprivate func getBuildingTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .primaryTitleGrey
        label.textAlignment = .left
        return label
    }
    
    fileprivate func getBuildingDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = .secondaryTitleGrey
        label.textAlignment = .left
        return label
    }
    
    fileprivate func getBuildingHoursLabel() -> UILabel{
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = UIColor.informationYellow
        label.textAlignment = .right
        return label
    }
}
