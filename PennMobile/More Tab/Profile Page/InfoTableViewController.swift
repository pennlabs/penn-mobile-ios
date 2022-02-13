//
//  InfoTableViewController.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 10/10/21.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import UIKit

class InfoTableViewController: UIViewController {

    let tableView = UITableView(frame: .zero)
    let searchController = UISearchController(searchResultsController: nil)
    var viewModel: InfoTableViewModel!
    var isMajors = true

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupViewModel()
        setupTableView()
        setupSearchController()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: false)
        viewModel.updateAccount()
    }

    func setupView() {
        if isMajors {
            self.title = "Majors"
        } else {
            self.title = "Schools"
        }
        view.backgroundColor = .uiGroupedBackground
    }

    func setupViewModel() {
        viewModel = InfoTableViewModel()
        viewModel.isMajors = self.isMajors
        viewModel.delegate = self
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
        searchController.searchResultsUpdater = viewModel
    }

    func setupTableView() {

        view.addSubview(tableView)
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsMultipleSelection = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
    }

    func setupSearchController() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.obscuresBackgroundDuringPresentation = false
        self.tableView.tableHeaderView = searchController.searchBar
    }

}
extension InfoTableViewController: InfoTableViewModelDelegate {
    func reloadTableData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
