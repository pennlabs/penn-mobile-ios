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
    static let cellHeight: CGFloat = 86
    
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
    
    var isHomepage: Bool = false {
        didSet {
            setupCell(with: schedule)
        }
    }
    
    // MARK: - UI Elements
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    
    fileprivate var venueImageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    fileprivate var timesLabel: UILabel!
    fileprivate var statusLabel: UILabel!
    
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
extension FitnessHourCell {
    
    fileprivate func setupCell(with name: FitnessFacilityName) {
        titleLabel.text = name.getFacilityName()
        
        // Label will say nothing by default
        statusLabel.text = ""
        statusLabel.textColor = .secondaryInformationGrey
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
            statusLabel.textColor = .informationYellow
            statusLabel.font = .primaryInformationFont
        } else {
            statusLabel.text = "CLOSED"
            statusLabel.textColor = .secondaryInformationGrey
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
        //self.accessoryType = .disclosureIndicator
        self.accessoryType = .none
        prepareSafeArea()
        prepareImageView()
        prepareLabels()
    }
    
    // MARK: Safe Area
    fileprivate func prepareSafeArea() {
        safeArea = getSafeAreaView()
        addSubview(safeArea)
        
        safeArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: safeInsetValue).isActive = true
        safeArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -safeInsetValue).isActive = true
        safeArea.topAnchor.constraint(equalTo: topAnchor, constant: safeInsetValue / 2).isActive = true
        safeArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -safeInsetValue / 2).isActive = true
    }
    
    // MARK: ImageView
    fileprivate func prepareImageView() {
        venueImageView = getVenueImageView()
        addSubview(venueImageView)
        
        venueImageView.widthAnchor.constraint(equalToConstant: 130).isActive = true
        venueImageView.heightAnchor.constraint(equalToConstant: 72).isActive = true
        venueImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        venueImageView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor).isActive = true
    }
    
    // MARK: Labels
    fileprivate func prepareLabels() {
        titleLabel = getTitleLabel()
        addSubview(titleLabel)
        statusLabel = getStatusLabel()
        addSubview(statusLabel)
        timesLabel = getTimeLabel()
        addSubview(timesLabel)
        
        titleLabel.leadingAnchor.constraint(equalTo: venueImageView.trailingAnchor,
                                            constant: safeInsetValue).isActive = true
        
        titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        
        statusLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        statusLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        timesLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        timesLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 3).isActive = true
        timesLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
    }
}

// MARK: - Define UI Elements
extension FitnessHourCell {
    
    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate func getVenueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    fileprivate func getTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = .primaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shrinkUntilFits()
        return label
    }
    
    fileprivate func getTimeLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryInformationFont
        label.textColor = .secondaryInformationGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shrinkUntilFits()
        return label
    }
    
    fileprivate func getStatusLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryInformationFont
        label.textColor = .informationYellow
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}

