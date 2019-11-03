//
//  DiningControllerCell.swift
//  PennMobile
//
//  Created by Josh Doman on 3/30/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//
import UIKit

class DiningCell: UITableViewCell {
    
    static let identifier = "diningVenueCell"
    static let cellHeight: CGFloat = 86
    
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
    fileprivate let safeInsetValue: CGFloat = 14
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
        venueImageView.kf.setImage(with: venue.imageURL)
        titleLabel.text = venue.name
        updateTimeLabel(with: venue)
        
        if venue.hasMealsToday {
            if venue.isOpen {
                statusLabel.text = "Open"
                statusLabel.textColor = .baseYellow
                statusLabel.font = .primaryInformationFont
            } else if let nextMeal = venue.nextMeal {
                statusLabel.text = "Opens in \(Date().humanReadableDistanceFrom(nextMeal.open))"
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
        statusLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 2).isActive = true
        
        timesLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        timesLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 3).isActive = true
        timesLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
    }
}

// MARK: - Define UI Elements
extension DiningCell {
    
    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate func getVenueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .grey2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    fileprivate func getTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}

