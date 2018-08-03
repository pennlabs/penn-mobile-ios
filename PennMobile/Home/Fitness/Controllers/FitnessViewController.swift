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
        
        tableView.separatorStyle = .singleLine
        //self.screenName = "Fitness"
        
        self.registerHeadersAndCells(for: tableView)
        tableView.dataSource = self
        tableView.delegate = self
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

// MARK: - UITableViewDataSource
extension FitnessViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? viewModel.activeFacilities().count : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FitnessHourCell.identifier, for: indexPath) as! FitnessHourCell
        cell.schedule = viewModel.getFacility(for: indexPath)
        return cell
    }
    
    func registerHeadersAndCells(for tableView: UITableView) {
        tableView.register(FitnessHourCell.self, forCellReuseIdentifier: FitnessHourCell.identifier)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FitnessHourCell.cellHeight
    }
}
