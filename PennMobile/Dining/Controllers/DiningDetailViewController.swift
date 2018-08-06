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
        
        // Override the default table view with a grouped style
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        tableView.separatorStyle = .none
        
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        DiningMenuAPI.instance.fetchDiningMenu(for: venue.name) { (success) in
            DispatchQueue.main.async {
                if success {
                    self.tableView.reloadData()
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
        return (venue.meals != nil) ? 5 : 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return BuildingHeaderCell.cellHeight
        case 1: return BuildingImageCell.cellHeight
        case 2: return BuildingHoursCell.cellHeight
        case 3:
            if venue.meals != nil {
                return requestedCellHeights[BuildingFoodMenuCell.identifier]!
            } else {
                return BuildingMapCell.cellHeight
            }
        case 4: return BuildingMapCell.cellHeight
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : BuildingCell
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: BuildingHeaderCell.identifier, for: indexPath) as! BuildingHeaderCell
            (cell as! BuildingHeaderCell).building = self.venue
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: BuildingImageCell.identifier, for: indexPath) as! BuildingImageCell
            (cell as! BuildingImageCell).building = self.venue
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: BuildingHoursCell.identifier, for: indexPath) as! BuildingHoursCell
            (cell as! BuildingHoursCell).building = self.venue
        case 3:
            if venue.meals != nil {
                cell = tableView.dequeueReusableCell(withIdentifier: BuildingFoodMenuCell.identifier, for: indexPath) as! BuildingFoodMenuCell
                (cell as! BuildingFoodMenuCell).building = self.venue
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: BuildingMapCell.identifier, for: indexPath) as! BuildingMapCell
                (cell as! BuildingMapCell).building = self.venue
            }
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: BuildingMapCell.identifier, for: indexPath) as! BuildingMapCell
            (cell as! BuildingMapCell).building = self.venue
        default: cell = BuildingCell()
        }
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
    
    // Section headers
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0.0
        case 1: return 0.0
        case 2: return BuildingSectionHeader.headerHeight
        case 3: return BuildingSectionHeader.headerHeight
        case 4: return BuildingSectionHeader.headerHeight
        default: return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0: return nil
        case 1: return nil
        case 2: let header = BuildingSectionHeader(); header.label.text = "Hours"; return header
        case 3:
            if venue.meals != nil {
                let header = BuildingSectionHeader(); header.label.text = "Menu"; return header
            } else {
                let header = BuildingSectionHeader(); header.label.text = "Map"; return header
            }
        case 4: let header = BuildingSectionHeader(); header.label.text = "Map"; return header
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: - UITableViewDelegate
extension DiningDetailViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) as? BuildingMapCell {
            let mapViewController = MapViewController()
            navigationController?.pushViewController(mapViewController, animated: true)
            mapViewController.building = cell.building
        }
        //}
        /*if let cell = tableView.cellForRow(at: indexPath) as? BuildingFoodMenuCell {
            if menuCellExpanded {
                menuCellExpanded = false
                cell.isExpanded = false
                requestedCellHeights[BuildingFoodMenuCell.identifier] = BuildingFoodMenuCell.cellHeight
                tableView.reloadRows(at: [indexPath], with: .automatic)
                cell.setupCell()
            } else {
                menuCellExpanded = true
                cell.isExpanded = true
                requestedCellHeights[BuildingFoodMenuCell.identifier] = cell.getMenuRequiredHeight()
                tableView.reloadRows(at: [indexPath], with: .automatic)
                cell.setupCell()
            }
        }*/
    }

}
