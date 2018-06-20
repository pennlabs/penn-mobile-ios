//
//  DiningDetailViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/31/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class DiningDetailViewController: UITableViewController {
    
    var venue: DiningVenue! {
        didSet {
            updateUI(with: venue)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .yellow
    }
}

// MARK: - Setup and Update UI
extension DiningDetailViewController {

    fileprivate func updateUI(with venue: DiningVenue) {
        
        /*buildingTitleLabel.text = venue.name.rawValue
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
        }*/
    }
}

// MARK: - UITableViewDataSource
extension DiningDetailViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BuildingImageCell.identifier, for: indexPath) as! BuildingImageCell
        //cell.venue = //getVenue(for: indexPath)
        return cell
    }
    
    func registerHeadersAndCells(for tableView: UITableView) {
        tableView.register(BuildingImageCell.self, forCellReuseIdentifier: BuildingImageCell.identifier)
        tableView.register(BuildingHeaderView.self, forHeaderFooterViewReuseIdentifier: BuildingHeaderView.identifier)
    }
}

// MARK: - UITableViewDelegate
extension DiningDetailViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: BuildingHeaderView.identifier) as! BuildingHeaderView
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BuildingImageCell.cellHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return BuildingHeaderView.headerHeight
    }

}
