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
    
    fileprivate var groups: [GSRGroup]!
    
    fileprivate var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let member = GSRGroupMember(accountID: "1", first: "Amy", last: "Gutmann", email: "amyg@upenn.edu", enabled: true)
        self.groups = [GSRGroup(groupID: "1", groupName: "Penn Labs Babies", createdAt: Date(), isActive: true, members: [member, member])]
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

// MARK: - Setup UI
extension GSRGroupController {
    fileprivate func setupUI() {
        setupTableView()
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
        if indexPath.row == 0 {
            return tableView.dequeueReusableCell(withIdentifier: CreateGroupCell.identifier, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupCell.identifier, for: indexPath) as! GroupCell
            cell.group = groups[indexPath.row - 1]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return CreateGroupCell.cellHeight
        } else {
            return GroupCell.cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tap")
    }
}
