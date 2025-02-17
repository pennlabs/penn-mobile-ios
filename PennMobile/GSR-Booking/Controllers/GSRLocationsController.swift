//
//  GSRLocationsController.swift
//  PennMobile
//
//  Created by Josh Doman on 4/6/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class GSRLocationsController: GenericViewController {

    fileprivate var locations: [GSRLocation]!

    fileprivate var tableView: UITableView!

    var group: GSRGroup?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.locations = GSRLocationModel.shared.getLocations()
        setupTableView()
    }
        
    override func setupNavBar() {
        super.setupNavBar()
        self.tabBarController?.title = "Study Room Booking"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.locations = GSRLocationModel.shared.getLocations()
        tableView.reloadData()
    }
}

// MARK: - Setup UI
extension GSRLocationsController {
    fileprivate func setupTableView() {
        tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.register(GSRLocationCell.self, forCellReuseIdentifier: GSRLocationCell.identifier)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension GSRLocationsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GSRLocationCell.identifier, for: indexPath) as! GSRLocationCell
        cell.location = locations[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GSRLocationCell.cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = locations[indexPath.row]
        let gc = GSRController()
        gc.group = group
        gc.startingLocation = location
        gc.title = "Tap to book"
        gc.toastPresentingController = resolveToastPresentingController()
        navigationController?.pushViewController(gc, animated: true)
    }
}
