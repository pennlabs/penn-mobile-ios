//
//  DiningDetailViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/31/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class DiningDetailViewController: GenericViewController {
    
    var venue: DiningVenue!

    fileprivate var stackView: UIStackView!

    fileprivate var primaryLabel: UILabel!
    fileprivate var secondaryLabel: UILabel!
    fileprivate var venueImageView: UIImageView!
    fileprivate var timeLabel: UILabel!
    fileprivate var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .yellow
        self.setupUI()
    }
}


// MARK: - Initialize UI elements
extension DiningDetailViewController {
	fileprivate func setupUI() {
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
