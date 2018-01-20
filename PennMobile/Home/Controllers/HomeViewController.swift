//
//  HomeViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: GenericViewController {
    
    var viewModel: HomeViewModel!
    
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        view.backgroundColor = .white
        
        trackScreen = true
        
        viewModel = HomeViewModel()
        viewModel.delegate = self
        
        prepareTableView()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.update()
        tableView.reloadData()
        
        fetchAndReloadData()
    }
}

// MARK: - Prepare TableView
extension HomeViewController {
    func prepareTableView() {
        tableView = UITableView()
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
        
        view.addSubview(tableView)
        
        tableView.anchorToTop(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor)
        if #available(iOS 11.0, *) {
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0).isActive = true
            tableView.bottomAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0).isActive = true
        }
        
        registerTableViewCells()
    }
    
    func registerTableViewCells() {
        tableView.register(HomeEventCell.self, forCellReuseIdentifier: HomeEventCell.identifier)
        tableView.register(HomeDiningCell.self, forCellReuseIdentifier: HomeDiningCell.identifier)
        tableView.register(HomeLaundryCell.self, forCellReuseIdentifier: HomeLaundryCell.identifier)
        tableView.register(HomeStudyRoomCell.self, forCellReuseIdentifier: HomeStudyRoomCell.identifier)
    }
}

// MARK: - ViewModelDelegate
extension HomeViewController: HomeViewModelDelegate {
    func handleTransition(to page: Page) {
        // Make any UI changes before transition here
        ControllerModel.shared.transition(to: page, withAnimation: true)
    }
}

// MARK: - Networking
extension HomeViewController {
    func fetchAndReloadData() {
        HomeAPIService.instance.fetchData(for: viewModel.items) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
