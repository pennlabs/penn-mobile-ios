//
//  FitnessViewController.swift
//  PennMobile
//
//  Created by raven on 7/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class FitnessViewController: GenericTableViewController {
    
    fileprivate var viewModel = FitnessViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        
        self.screenName = "Fitness"
        
        viewModel.registerHeadersAndCells(for: tableView)
        
        tableView.dataSource = viewModel
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
