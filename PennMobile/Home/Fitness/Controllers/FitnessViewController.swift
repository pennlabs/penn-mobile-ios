//
//  FitnessViewController.swift
//  PennMobile
//
//  Created by raven on 7/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class FitnessViewController: UITableViewController {
    
    fileprivate var viewModel = FitnessViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        self.title = "Fitness"
        
        self.registerHeadersAndCells(for: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFitnessHours()
        self.tabBarController?.title = "Fitness"
    }
}

//Mark: Networking to retrieve today's times
extension FitnessViewController {
    fileprivate func fetchFitnessHours() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FitnessAPI.instance.fetchFitnessHours { (success) in
            DispatchQueue.main.async {
                if success {
                    self.tableView.reloadData()
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension FitnessViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension FitnessViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? viewModel.pottruckFacilities.count : viewModel.otherFacilities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FitnessHourCell.identifier, for: indexPath) as! FitnessHourCell
        if indexPath.section == 0 {
            cell.name = viewModel.pottruckFacilities[indexPath.row]
            cell.schedule = viewModel.getPottruckFacility(for: indexPath.row)
        } else if indexPath.section == 1 {
            cell.name = viewModel.otherFacilities[indexPath.row]
            cell.schedule = viewModel.getOtherFacility(for: indexPath.row)
        }
        return cell
    }
    
    func registerHeadersAndCells(for tableView: UITableView) {
        tableView.register(FitnessHourCell.self, forCellReuseIdentifier: FitnessHourCell.identifier)
        tableView.register(FitnessHeaderView.self, forHeaderFooterViewReuseIdentifier: FitnessHeaderView.identifier)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FitnessHourCell.cellHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: FitnessHeaderView.identifier) as! FitnessHeaderView
        
        let headerTitle: String = (section == 0 ? "Pottruck" : "Other Facilities")
        view.label.text = headerTitle
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return FitnessHeaderView.headerHeight
    }
}
