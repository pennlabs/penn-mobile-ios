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

    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .yellow
        self.prepareUI()
    }
}

// MARK: - Setup and Update UI
extension DiningDetailTVC {

    fileprivate func updateUI(with venue: DiningVenue) {
        
        buildingTitleLabel.text = venue.name.rawValue
        buildingTypeLabel.text = "Dining Hall"

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

// MARK: - UITableViewDataSource
extension DiningDetailTVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: diningCell, for: indexPath) as! DiningCell
        cell.venue = getVenue(for: indexPath)
        return cell
    }
    
    func registerHeadersAndCells(for tableView: UITableView) {
        tableView.register(DiningCell.self, forCellReuseIdentifier: diningCell)
        tableView.register(DiningHeaderView.self, forHeaderFooterViewReuseIdentifier: headerView)
        tableView.register(AnnouncementHeaderView.self, forHeaderFooterViewReuseIdentifier: announcementHeader)
    }
}

// MARK: - UITableViewDelegate
extension DiningDetailTVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BuildingHeaderView") as! BuildingHeaderView
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BuildingImageCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return BuildingHeaderView.headerHeight
    }
    
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let venue = getVenue(for: indexPath)
        delegate?.handleSelection(for: venue)
    }*/
}

// MARK: - Initialize and Prepare UI
extension BuildingImageTableViewCell {

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
        layoutSubviews(stackView)
        
        if venue != nil { updateUI(with: venue) }
    }
    }

    fileprivate func prepareImageView() {
        buildingImageView = getBuildingImageView()
        addSubview(buildingImageView)

        buildingImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        buildingImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        buildingImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        buildingImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

//MARK: - Define UI Elements
extension BuildingImageTableViewCell {
    fileprivate func getBuildingImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
}

/*


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
*/