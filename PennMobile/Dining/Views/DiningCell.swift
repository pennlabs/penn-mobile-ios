//
//  DiningControllerCell.swift
//  PennMobile
//
//  Created by Josh Doman on 3/30/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//
import UIKit
import SnapKit

class DiningCell: UITableViewCell {
    
    static let identifier = "diningVenueCell"
    static let cellHeight: CGFloat = 110
    
    var venue: DiningVenue! {
        didSet {
            setupCell(with: venue)
        }
    }
    
    var isHomepage: Bool = false {
        didSet {
            setupCell(with: venue)
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
extension DiningCell {
    fileprivate func setupCell(with venue: DiningVenue) {
        backgroundColor = .clear
        venueImageView.kf.setImage(with: venue.imageURL)
        titleLabel.text = venue.name
        updateTimeLabel(with: venue)
        
        if venue.hasMealsToday {
            if let meal = venue.currentMeal {
                if meal.isLight {
                    // Label will read: "Light Lunch" or "Light Breakfast"
                    statusLabel.text = meal.type
                    statusLabel.textColor = .baseYellow
                    statusLabel.font = .primaryInformationFont
                } else {
                    statusLabel.text = "Open"
                    statusLabel.textColor = .baseYellow
                    statusLabel.font = .primaryInformationFont
                }
            } else if let nextMeal = venue.nextMeal {
                statusLabel.text = "Opens \(Date().humanReadableDistanceFrom(nextMeal.open))"
                statusLabel.textColor = .labelSecondary
                statusLabel.font = .secondaryInformationFont
            } else {
                statusLabel.text = "Closed"
                statusLabel.textColor = .labelSecondary
                statusLabel.font = .secondaryInformationFont
            }
        } else {
            statusLabel.text = "Closed Today"
            statusLabel.textColor = .labelSecondary
            statusLabel.font = .secondaryInformationFont
        }
    }
    
    fileprivate func updateTimeLabel(with venue: DiningVenue) {
        timesLabel.text = venue.humanFormattedHoursStringForToday
        timesLabel.layoutIfNeeded()
    }
}

// MARK: - Initialize and Layout UI Elements
extension DiningCell {
    
    fileprivate func prepareUI() {
        self.accessoryType = .disclosureIndicator
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
extension DiningCell {
    
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

