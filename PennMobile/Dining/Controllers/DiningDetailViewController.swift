//
//  DiningDetailViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/31/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class DiningDetailTVC: UITableViewController {
    
    var venue: DiningVenue! {
        didSet {
            updateUI(with: venue)
        }
    }

    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!

    fileprivate var buildingTitleLabel: UILabel!
    fileprivate var buildingTypeLabel: UILabel!
    fileprivate var buildingHoursLabel: UILabel!
    fileprivate var buildingImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .yellow
        self.prepareUI()
    }

    fileprivate func updateUI(with venue: DiningVenue) {
        
    	primaryLabel.text = venue.name.rawValue
        secondaryLabel.text = "Dining Hall"
        venueImageView.image = UIImage(named: venue.name.rawValue.folding(options: .diacriticInsensitive, locale: .current))
        
        updateTimeLabel(with: venue.times)
        
        if venue.times != nil, venue.times!.isEmpty {
            statusLabel.text = "CLOSED TODAY"
            statusLabel.textColor = .secondaryInformationGrey
            statusLabel.font = .secondaryInformationFont
        } else if venue.times != nil && venue.times!.isOpen {
            statusLabel.text = "OPEN"
            statusLabel.textColor = .informationYellow
            statusLabel.font = .primaryInformationFont
        } else {
            statusLabel.text = "CLOSED"
            statusLabel.textColor = .secondaryInformationGrey
            statusLabel.font = .secondaryInformationFont
        }
    }
    
    fileprivate func updateTimeLabel(with times: [OpenClose]?) {
        timeLabel.text = times?.strFormat
        timeLabel.layoutIfNeeded()
    }
}


// MARK: - Initialize UI elements
extension DiningDetailTVC {
	fileprivate func prepareUI() {
		prepareSafeArea()

        primaryLabel = getPrimaryLabel()
        secondaryLabel = getSecondaryLabel()
        venueImageView = getVenueImageView()
        timeLabel = getTimeLabel()
        statusLabel = getStatusLabel()

        // Initialize and setup stackView
        let arrangedSubviews: [UIView] = [primaryLabel, secondaryLabel, venueImageView, timeLabel, statusLabel]
        stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        configure(stackView)
        layout(stackView)
        layoutSubviews(stackView)
        
        if venue != nil { updateUI(with: venue) }
    }
    
    fileprivate func configure(_ sv: UIStackView) {
        sv.axis = .vertical
        sv.distribution = .fillProportionally
        sv.alignment = .fill
        sv.spacing = 10
        sv.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func layout(_ sv: UIStackView) {
        self.view.addSubview(sv)

        sv.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        sv.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        sv.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        sv.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
    }

    fileprivate func layoutSubviews(_ sv: UIStackView) {
    	prepareImageView()
    }

    private func prepareSafeArea() {
        safeArea = getSafeAreaView()
        
        view.addSubview(safeArea)
        
        safeArea.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: safeInsetValue).isActive = true
        safeArea.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -safeInsetValue).isActive = true
        safeArea.topAnchor.constraint(equalTo: view.topAnchor, constant: safeInsetValue).isActive = true
        safeArea.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -safeInsetValue).isActive = true
    }

    fileprivate func prepareImageView() {       
        buildingImageView.widthAnchor.constraint(equalToConstant: 130).isActive = true
        buildingImageView.heightAnchor.constraint(equalToConstant: 72).isActive = true
        buildingImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
    }

    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    fileprivate func getPrimaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .primaryTitleGrey
        
        label.backgroundColor = .green
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

   	fileprivate func getSecondaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .secondaryTitleGrey
        
        label.backgroundColor = .green
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    fileprivate func getTimeLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryInformationFont
        label.textColor = .secondaryInformationGrey
        
        label.backgroundColor = .green
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

    fileprivate func getVenueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

}
