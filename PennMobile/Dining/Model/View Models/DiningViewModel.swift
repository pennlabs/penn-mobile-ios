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
    
    let balancesHeader = "Dining Balances"
    let diningHeader = "Dining Halls"
    let retailHeader = "Retail Dining"
    
    var delegate: DiningViewModelDelegate?
    
    internal let headerView = "headerView"
    internal let diningCell = "diningCell"
    internal let diningBalancesCell = "diningBalancesCell"
    internal let announcementHeader = "announcementHeader"
    
    var shouldShowAnnouncement = false
    var shouldShowDiningBalances = true
    var announcement: String?
    
    func getType(forSection section: Int) -> DiningVenueType {
        let index = shouldShowAnnouncement ? section - 2 : section - 1
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
        return ordering.count + (shouldShowAnnouncement ? 1 : 0) + (shouldShowDiningBalances ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowAnnouncement && section == 0 {
            return 0
        }
        if shouldShowAnnouncement && section == 1 || !shouldShowAnnouncement && section == 0 {
            return 1
        }
        return getVenues(forSection: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (!shouldShowAnnouncement && indexPath.section == 0 || shouldShowAnnouncement && indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: diningBalancesCell, for: indexPath) as! DiningBalancesCell
            cell.selectionStyle = .none
            cell.diningBalances = DiningBalances(hasDiningPlan: true, planName: "Test", diningDollars: "$97.23", visits: 48, guestVisits: 0)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: diningCell, for: indexPath) as! DiningCell
        cell.venue = getVenue(for: indexPath)
        return cell
    }
    
    func registerHeadersAndCells(for tableView: UITableView) {
        tableView.register(DiningCell.self, forCellReuseIdentifier: diningCell)
        tableView.register(DiningBalancesCell.self, forCellReuseIdentifier: diningBalancesCell)
        tableView.register(DiningHeaderView.self, forHeaderFooterViewReuseIdentifier: headerView)
        tableView.register(AnnouncementHeaderView.self, forHeaderFooterViewReuseIdentifier: announcementHeader)
    }
}

// MARK: - UITableViewDelegate
extension DiningViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if shouldShowAnnouncement && section == 0 {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: announcementHeader) as! AnnouncementHeaderView
            view.announcement = announcement ?? ""
            return view
        } else if shouldShowAnnouncement && section == 1 || !shouldShowAnnouncement && section == 0 {
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
        if (!shouldShowAnnouncement && indexPath.row == 0 || shouldShowAnnouncement && indexPath.row == 1) {
            return DiningBalancesCell.cellHeight
        }
        return DiningCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (shouldShowAnnouncement && section == 0) ? AnnouncementHeaderView.headerHeight : DiningHeaderView.headerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ((!shouldShowAnnouncement && indexPath.section > 0 || shouldShowAnnouncement && indexPath.section > 1)) {
            let venue = getVenue(for: indexPath)
            delegate?.handleSelection(for: venue)
        }
    }
}
