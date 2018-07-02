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
            fetchDiningMenus()
            updateUI(with: venue)
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerHeadersAndCells(for: self.tableView)
        self.view.backgroundColor = .white
    }
    
    var menuCellExpanded = false
    var requestedCellHeights: Dictionary<String, CGFloat> = [
        BuildingHeaderCell.identifier: BuildingHeaderCell.cellHeight,
        BuildingImageCell.identifier: BuildingImageCell.cellHeight,
        BuildingMapCell.identifier: BuildingMapCell.cellHeight,
        BuildingHoursCell.identifier: BuildingHoursCell.cellHeight,
        BuildingFoodMenuCell.identifier: BuildingFoodMenuCell.cellHeight
    ]
}

//Mark: Networking to retrieve today's menus
extension DiningDetailViewController {
    fileprivate func fetchDiningMenus() {
        //UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        DiningMenuAPI.instance.fetchDiningMenu(for: venue.name) { (success) in
            DispatchQueue.main.async {
                if success {
                    self.tableView.reloadData()
                }
                //UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}

// MARK: - Setup and Update UI
extension DiningDetailViewController {

    fileprivate func updateUI(with venue: DiningVenue) {

    }
}

// MARK: - UITableViewDataSource
extension DiningDetailViewController: CellUpdateDelegate {
    
    func cellRequiresNewLayout(with height: CGFloat, for cell: String) {
        requestedCellHeights[cell] = height
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return BuildingHeaderCell.cellHeight
        case 1: return BuildingImageCell.cellHeight
        case 2: return BuildingHoursCell.cellHeight
        case 3: return requestedCellHeights[BuildingFoodMenuCell.identifier]!
        case 4: return BuildingMapCell.cellHeight
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : BuildingCell
        switch indexPath.row {
        case 0: cell = tableView.dequeueReusableCell(withIdentifier: BuildingHeaderCell.identifier, for: indexPath) as! BuildingHeaderCell
        case 1: cell = tableView.dequeueReusableCell(withIdentifier: BuildingImageCell.identifier, for: indexPath) as! BuildingImageCell
        case 2: cell = tableView.dequeueReusableCell(withIdentifier: BuildingHoursCell.identifier, for: indexPath) as! BuildingHoursCell
        case 3: cell = tableView.dequeueReusableCell(withIdentifier: BuildingFoodMenuCell.identifier, for: indexPath) as! BuildingFoodMenuCell
        case 4: cell = tableView.dequeueReusableCell(withIdentifier: BuildingMapCell.identifier, for: indexPath) as! BuildingMapCell
        default: cell = BuildingCell()
        }
        cell.venue = self.venue
        cell.selectionStyle = .none
        return cell
    }
    
    func registerHeadersAndCells(for tableView: UITableView) {
        tableView.register(BuildingHeaderCell.self, forCellReuseIdentifier: BuildingHeaderCell.identifier)
        tableView.register(BuildingImageCell.self, forCellReuseIdentifier: BuildingImageCell.identifier)
        tableView.register(BuildingHoursCell.self, forCellReuseIdentifier: BuildingHoursCell.identifier)
        tableView.register(BuildingFoodMenuCell.self, forCellReuseIdentifier: BuildingFoodMenuCell.identifier)
        tableView.register(BuildingMapCell.self, forCellReuseIdentifier: BuildingMapCell.identifier)
    }
}

// MARK: - UITableViewDelegate
extension DiningDetailViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = tableView.cellForRow(at: indexPath) as? BuildingFoodMenuCell {
            if menuCellExpanded {
                menuCellExpanded = !menuCellExpanded
                requestedCellHeights[BuildingFoodMenuCell.identifier] = 150
                tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                menuCellExpanded = !menuCellExpanded
                requestedCellHeights[BuildingFoodMenuCell.identifier] = 400
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    /*override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: BuildingHeaderView.identifier) as! BuildingHeaderView
        view.venue = self.venue
        return view
    }*/
    
    /*override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return BuildingHeaderView.headerHeight
    }*/

}
