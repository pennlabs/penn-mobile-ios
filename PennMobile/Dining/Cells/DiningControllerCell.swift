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
    
    // MARK: - UI Elements
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    
    fileprivate var venueImageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    fileprivate var timesLabel: UILabel!
    fileprivate var statusLabel: UILabel!
    fileprivate var menuButton: UIButton!
    fileprivate var locationButton: UIButton!
    
    // MARK: - Init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func menuButtonTapped() {
        print("Menu button Tapped!")
    }
    
    @objc fileprivate func locationButtonTapped() {
        print("Location button Tapped!")
    }
}

// MARK: - Setup Cell
extension DiningCell {
    fileprivate func setupCell(with venue: DiningVenue) {
        venueImageView.image = UIImage(named: venue.name.rawValue.folding(options: .diacriticInsensitive, locale: .current))
        titleLabel.text = venue.name.rawValue
        updateTimeLabel(with: venue.times)
        if venue.times != nil, venue.times!.isEmpty {
            statusLabel.text = "CLOSED TODAY"
            statusLabel.textColor = .secondaryInformationGrey
            statusLabel.font = .secondaryInformationFont
        } else {
            statusLabel.text = "OPEN"
            statusLabel.textColor = .informationYellow
            statusLabel.font = .primaryInformationFont
        }
    }
    
    fileprivate func updateTimeLabel(with times: [OpenClose]?) {
        timesLabel.text = times?.strFormat
        if let times = times, times.count > 3 {
            timesLabel.shrinkUntilFits(numberOfLines: 1, increment: 0.5)
        }
    }
}

// MARK: - Initialize and Layout UI Elements
extension DiningCell {
    
    fileprivate func prepareUI() {
        
        prepareSafeArea()
        prepareImageView()
        prepareLabels()
        prepareButtons()
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
        titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        
        statusLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3).isActive = true
        //statusLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        timesLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        timesLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 3).isActive = true
    }
    
    // MARK: Buttons
    fileprivate func prepareButtons() {
        let buttonSize: CGFloat = 20
        
        menuButton = getMenuButton()
        addSubview(menuButton)
        
        menuButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        menuButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        menuButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        menuButton.bottomAnchor.constraint(equalTo: venueImageView.bottomAnchor).isActive = true
        
        locationButton = getLocationButton()
        addSubview(locationButton)
        
        locationButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        locationButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        locationButton.leadingAnchor.constraint(equalTo: menuButton.trailingAnchor, constant: 14).isActive = true
        locationButton.bottomAnchor.constraint(equalTo: menuButton.bottomAnchor).isActive = true
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
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    fileprivate func getTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = .primaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getTimeLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryInformationFont
        label.textColor = .secondaryInformationGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    fileprivate func getMenuButton() -> UIButton {
        let button = UIButton()/*
         button.setImage(UIImage(named: "menu-icon"), for: .normal)
         button.setImage(UIImage(named: "Available-GSR-Enabled"), for: .selected)
         button.setImage(UIImage(named: "Available-GSR-Enabled"), for: .highlighted)
         button.setImage(UIImage(named: "Disabled-GSR"), for: .disabled)*/
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    fileprivate func getLocationButton() -> UIButton {
        let button = UIButton()/*
         button.setImage(UIImage(named: "location-icon"), for: .normal)
         button.setImage(UIImage(named: "Available-GSR-Enabled"), for: .selected)
         button.setImage(UIImage(named: "Available-GSR-Enabled"), for: .highlighted)
         button.setImage(UIImage(named: "Disabled-GSR"), for: .disabled)*/
        button.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}

