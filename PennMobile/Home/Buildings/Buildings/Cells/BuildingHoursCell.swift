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
    static let cellHeight: CGFloat = 168
    static let numDays: Int = 7
    
    var building: BuildingHoursDisplayable! {
        didSet {
            setupCell(with: building)
        }
    }
    
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    fileprivate var dayLabels: [UILabel]!
    fileprivate var hourLabels: [UILabel]!
    
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
extension BuildingHoursCell {
    
    fileprivate func setupCell(with building: BuildingHoursDisplayable) {
        let weekdayArray = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let timeStringsForWeek = building.getTimeStrings()
        
        for day in 0 ..< BuildingHoursCell.numDays {
            let dayLabel = dayLabels[day]
            let hourLabel = hourLabels[day]
            dayLabel.text = weekdayArray[day]
            hourLabel.text = timeStringsForWeek[day]
            if weekdayArray[day] == Date.currentDayOfWeek {
                dayLabel.font = .primaryInformationFont
                dayLabel.textColor = .baseGreen
                hourLabel.font = .primaryInformationFont
                hourLabel.textColor = .baseGreen
            }
            // Shrink label if needed
            hourLabel.layoutIfNeeded()
        }
    }
}

// MARK: - Initialize and Prepare UI
extension BuildingHoursCell {
    
    fileprivate func prepareUI() {
        prepareSafeArea()
        
        dayLabels = [UILabel](); hourLabels = [UILabel]()
        
        for _ in 0 ..< BuildingHoursCell.numDays {
            dayLabels.append(getDayLabel())
            hourLabels.append(getHourLabel())
        }
        layoutLabels()
    }
    
    // MARK: Safe Area
    fileprivate func prepareSafeArea() {
        safeArea = getSafeAreaView()
        addSubview(safeArea)
        NSLayoutConstraint.activate([
            safeArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: safeInsetValue * 2),
            safeArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -safeInsetValue * 2),
            safeArea.topAnchor.constraint(equalTo: topAnchor, constant: safeInsetValue),
            safeArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -safeInsetValue)
        ])
    }
    
    // MARK: Layout Labels
    fileprivate func layoutLabels() {
        for day in 0 ..< BuildingHoursCell.numDays {
            let dayLabel = dayLabels[day]
            let hourLabel = hourLabels[day]
            
            addSubview(dayLabel)
            addSubview(hourLabel)
            
            if day == 0 {
                _ = dayLabel.anchor(safeArea.topAnchor, left: safeArea.leftAnchor, bottom: nil, right: nil)
                _ = hourLabel.anchor(safeArea.topAnchor, left: dayLabel.rightAnchor, bottom: nil, right: safeArea.rightAnchor)
            } else {
                _ = dayLabel.anchor(dayLabels[day - 1].bottomAnchor, left: safeArea.leftAnchor, topConstant: 0)
                _ = hourLabel.anchor(hourLabels[day - 1].bottomAnchor, left: safeArea.leftAnchor, right: safeArea.rightAnchor, topConstant: 0, leftConstant: 100)
            }
        }
    }
    
    fileprivate func getDayLabel() -> UILabel{
        let label = UILabel()
        label.font = .secondaryInformationFont
        label.textColor = UIColor.labelPrimary
        label.textAlignment = .left
        label.text = "Day"
        return label
    }
    
    fileprivate func getHourLabel() -> UILabel{
        let label = UILabel()
        label.font = .secondaryInformationFont
        label.textColor = UIColor.labelPrimary
        label.textAlignment = .right
        label.text = "Hour"
        label.shrinkUntilFits()
        return label
    }
    
    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
