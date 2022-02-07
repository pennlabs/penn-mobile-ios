//
//  GSRGroupController.swift
//  PennMobile
//
//  Created by Josh Doman on 4/6/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

//group gsrs!
class GSRGroupController: GenericViewController {

    fileprivate var groups: [GSRGroup] = []
    fileprivate var tableView: UITableView!
    fileprivate let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchGroups()
    }
}

// MARK: - Setup UI
extension GSRGroupController {
    fileprivate func setupUI() {
        setupTableView()
        
        //Add swipe up to refresh to Table View
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchGroups), for: .valueChanged)
//        tableView.addSubview(refreshControl)
    }

    fileprivate func setupTableView() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        view.addSubview(tableView)
        _ = tableView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)

        tableView.register(GroupCell.self, forCellReuseIdentifier: GroupCell.identifier)
        tableView.register(CreateGroupCell.self, forCellReuseIdentifier: CreateGroupCell.identifier)

    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension GSRGroupController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + groups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == groups.count {
            return tableView.dequeueReusableCell(withIdentifier: CreateGroupCell.identifier, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupCell.identifier, for: indexPath) as! GroupCell
            cell.group = groups[indexPath.row]
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == groups.count {
            return CreateGroupCell.cellHeight
        } else {
            return GroupCell.cellHeight
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == groups.count {
            let controller = GSRGroupNewIntialController()
            controller.delegate = self
            let navigationVC = UINavigationController(rootViewController: controller)
            controller.navigationController?.navigationBar.isHidden = true
            tableView.deselectRow(at: indexPath, animated: true)
            present(navigationVC, animated: true, completion: nil)
        } else {
            let group = groups[indexPath.row]
            let manageVC = GSRManageGroupController(group: group)
            tableView.deselectRow(at: indexPath, animated: true)
            navigationController?.pushViewController(manageVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

}

//MARK: NewGroupInitialDelegate
extension GSRGroupController: NewGroupInitialDelegate{
    @objc func fetchGroups() {
        GSRGroupNetworkManager.instance.getAllGroups { (groups) in
            if let groups = groups {
                self.groups = groups
            }

            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
}
