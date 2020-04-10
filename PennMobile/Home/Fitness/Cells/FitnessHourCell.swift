//
//  FitnessHourCell.swift
//  PennMobile
//
//  Created by raven on 7/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class FitnessHourCell: UITableViewCell {
    
    static let identifier = "fitnessHourCell"
    static let cellHeight: CGFloat = 110
    
    var schedule: FitnessSchedule! {
        didSet {
            setupCell(with: schedule)
        }
    }
    
    var name: FitnessFacilityName! {
        didSet {
            setupCell(with: name)
        }
    }
    
    // MARK: - UI Elements
    fileprivate var safeArea: UIView!
    fileprivate var venueImageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    fileprivate var timesLabel: UILabel!
    fileprivate var statusLabel: UILabel!
    
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
extension FitnessHourCell {
    
    fileprivate func setupCell(with name: FitnessFacilityName) {
        titleLabel.text = name.getFacilityName()
        statusLabel.text = ""
        statusLabel.textColor = .labelSecondary
        statusLabel.font = .secondaryInformationFont
        if let _ = name.getImageName() { venueImageView.image = UIImage(named: name.getImageName()!) }
    }
    
    fileprivate func setupCell(with schedule: FitnessSchedule?) {
        guard let schedule = schedule else {
            statusLabel.text = ""
            timesLabel.text = ""
            return
        }
        
        if !schedule.hours.isEmpty && schedule.hours.first?.start != nil && schedule.hours.first?.end != nil {
            updateTimeLabels(schedule.hours)
        }
        
    }
    
    fileprivate func updateTimeLabels(_ hours: [FitnessScheduleOpenClose]) {
        let now = Date()
        
        var isOpen = false
        for openClose in hours {
            guard openClose.start != nil && openClose.end != nil else { continue }
            if openClose.start! < now && openClose.end! > now { isOpen = true }
        }
        
        if isOpen {
            statusLabel.text = "OPEN"
            statusLabel.textColor = .baseYellow
            statusLabel.font = .primaryInformationFont
        } else {
            statusLabel.text = "CLOSED"
            statusLabel.textColor = .labelSecondary
            statusLabel.font = .secondaryInformationFont
        }
        
        var displayText = ""
        for oc in hours.indices {
            guard let start = hours[oc].start, let end = hours[oc].end else { continue }
            displayText += start.strFormat() + " - " + end.strFormat()
            if oc != hours.count - 1 { displayText += "  |  " }
        }
        timesLabel.text = displayText
        timesLabel.layoutIfNeeded()
    }
}

// MARK: - Initialize and Layout UI Elements
extension FitnessHourCell {
    
    fileprivate func prepareUI() {
        self.accessoryType = .none
        prepareSafeArea()
        prepareImageView()
        prepareLabels()
    }
    
    // MARK: Safe Area
    fileprivate func prepareSafeArea() {
        safeArea = UIView()
        addSubview(safeArea)
        
        safeArea.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(pad)
            make.trailing.equalTo(self).offset(-pad * 2)
            make.top.equalTo(self).offset(pad)
            make.bottom.equalTo(self).offset(-pad)
        }
    }
    
    // MARK: ImageView
    fileprivate func prepareImageView() {
        venueImageView = getVenueImageView()
        addSubview(venueImageView)
        
        venueImageView.snp.makeConstraints { (make) in
            make.width.equalTo(134)
            make.height.equalTo(86)
            make.leading.equalTo(safeArea)
            make.centerY.equalTo(safeArea)
        }
    }
    
    // MARK: Labels
    fileprivate func prepareLabels() {
        titleLabel = getTitleLabel()
        addSubview(titleLabel)
        statusLabel = getStatusLabel()
        addSubview(statusLabel)
        timesLabel = getTimeLabel()
        addSubview(timesLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(venueImageView)
            make.leading.equalTo(venueImageView.snp.trailing).offset(pad)
            make.trailing.equalTo(safeArea)
        }
        
        statusLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.leading)
            make.bottom.equalTo(titleLabel.snp.top).offset(-3)
        }
        
        timesLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.leading)
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.trailing.equalTo(safeArea)
        }
    }
}

// MARK: - Define UI Elements
extension FitnessHourCell {
    
    fileprivate func getVenueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .grey2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5.0
        return imageView
    }
    
    fileprivate func getTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        label.shrinkUntilFits()
        return label
    }
    
    fileprivate func getTimeLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryInformationFont
        label.textColor = .labelSecondary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shrinkUntilFits()
        return label
    }

    fileprivate func getStatusLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryInformationFont
        label.textColor = .baseYellow
        label.textAlignment = .left
        return label
    }
}

