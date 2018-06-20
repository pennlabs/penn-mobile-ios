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

}
