//
//  DiningDetailViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/31/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class DiningDetailViewController: GenericViewController {
    
    var venue: DiningVenue! {
        didSet {
            guard stackView != nil else { return }
            updateUI(with: venue)
        }
    }

    fileprivate var stackView: UIStackView!
    fileprivate var safeArea: UIView!

    fileprivate var primaryLabel: UILabel!
    fileprivate var secondaryLabel: UILabel!
    fileprivate var venueImageView: UIImageView!
    fileprivate var timeLabel: UILabel!
    fileprivate var statusLabel: UILabel!
    
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
extension DiningDetailViewController {
	fileprivate func prepareUI() {
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
        
        if venue != nil { updateUI(with: venue) }
    }
    
    fileprivate func configure(_ sv: UIStackView) {
        sv.axis = .vertical
        sv.distribution = .equalSpacing
        sv.alignment = .top
        sv.spacing = 10
        sv.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func layout(_ sv: UIStackView) {
        self.view.addSubview(sv)

        sv.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        sv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        sv.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        sv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func prepareSafeArea() {
        safeArea = getSafeAreaView()
        
        cardView.addSubview(safeArea)
        
        safeArea.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: safeInsetValue).isActive = true
        safeArea.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -safeInsetValue).isActive = true
        safeArea.topAnchor.constraint(equalTo: cardView.topAnchor, constant: safeInsetValue).isActive = true
        safeArea.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -safeInsetValue).isActive = true
    }

    fileprivate func getPrimaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .primaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

   	fileprivate func getSecondaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .secondaryTitleGrey
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
