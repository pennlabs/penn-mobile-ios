//
//  DiningViewModel.swift
//  PennMobile
//
//  Created by Josh Doman on 1/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

protocol DiningViewModelDelegate {
    func handleSelection(for venue: DiningVenue)
}

class DiningViewModel: NSObject {
    let ordering: [DiningVenueType] = [.dining, .retail]
    
    let dining = DiningVenue.getVenues(for: .dining)
    let retail = DiningVenue.getVenues(for: .retail)
    
    let balancesHeader = "Dining Balance"
    let diningHeader = "Dining Halls"
    let retailHeader = "Retail Dining"
    
    var balance: DiningBalance?
    
    var delegate: DiningViewModelDelegate?
    
    internal let headerView = "headerView"
    internal let diningCell = "diningCell"
    internal let diningBalanceCell = "diningBalanceCell"
    var shouldShowDiningBalances = true
    
    func getType(forSection section: Int) -> DiningVenueType {
        let index = shouldShowDiningBalances ? section - 1 : section
        return ordering[index]
    }
    
    func getVenues(forSection section: Int) -> [DiningVenue] {
        let type = getType(forSection: section)
        switch type {
        case .dining:
            return dining
        case .retail:
            return retail
        }
    }
    
    func getVenue(for indexPath: IndexPath) -> DiningVenue {
        return getVenues(forSection: indexPath.section)[indexPath.item]
    }
}

// MARK: - UITableViewDataSource
extension DiningViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ordering.count + (shouldShowDiningBalances ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowDiningBalances && section == 0 {
            return 1
        }
        return getVenues(forSection: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shouldShowDiningBalances && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: diningBalanceCell, for: indexPath) as! DiningBalanceCell
            cell.selectionStyle = .none
            
            if let balance = self.balance {
                cell.diningBalance = balance
            } else {
                cell.diningBalance = DiningBalance(hasDiningPlan: true, balancesAsOf: "",  planName: "", diningDollars: "$0.00", visits: 0, addOnVisits: 0, guestVisits: 0)
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: diningCell, for: indexPath) as! DiningCell
        cell.venue = getVenue(for: indexPath)
        return cell
    }
    
    func registerHeadersAndCells(for tableView: UITableView) {
        tableView.register(DiningCell.self, forCellReuseIdentifier: diningCell)
        tableView.register(DiningBalanceCell.self, forCellReuseIdentifier: diningBalanceCell)
        tableView.register(DiningHeaderView.self, forHeaderFooterViewReuseIdentifier: headerView)
    }
}

// MARK: - UITableViewDelegate
extension DiningViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if shouldShowDiningBalances && section == 0 {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerView) as! DiningHeaderView
            view.label.text = balancesHeader
            return view
        }
        else {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerView) as! DiningHeaderView
            
            let headerTitle: String
            let type = getType(forSection: section)
            switch type {
            case .dining:
                headerTitle = diningHeader
            case .retail:
                headerTitle = retailHeader
            }
            
            view.label.text = headerTitle
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if shouldShowDiningBalances && indexPath.section == 0 {
            return DiningBalanceCell.cellHeight
        }
        return DiningCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return DiningHeaderView.headerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldShowDiningBalances && indexPath.section > 0 || !shouldShowDiningBalances {
            let venue = getVenue(for: indexPath)
            delegate?.handleSelection(for: venue)
        }
    }
}
