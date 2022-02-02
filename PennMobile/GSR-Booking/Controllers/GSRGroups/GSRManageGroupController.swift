//
//  GSRMemberGroupController.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 10/18/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

class GSRManageGroupController: UIViewController {

    fileprivate var tableView: UITableView!
    fileprivate var viewModel: GSRManageGroupViewModel!
    var group: GSRGroup?
    fileprivate let refreshControl = UIRefreshControl()

    init(group: GSRGroup) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
       super.viewDidLoad()
        prepareViewModel()
        prepareUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchGroup()
    }
}

//MARK: UI Stuff
extension GSRManageGroupController {
    func prepareViewModel() {
        guard let group = group else { return }
        viewModel = GSRManageGroupViewModel(group: group)
        viewModel.delegate = self
    }

     func prepareUI() {
        prepareNavBar()
        prepareTableView()
    }

    private func prepareTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
        tableView.allowsSelection = false
        tableView.backgroundColor = .uiGroupedBackground
        tableView.separatorStyle = .none
        tableView.register(GroupMemberCell.self, forCellReuseIdentifier: GroupMemberCell.identifier)
        tableView.register(GroupSettingsCell.self, forCellReuseIdentifier: GroupSettingsCell.identifier)
        tableView.register(GroupManageButtonCell.self, forCellReuseIdentifier: GroupManageButtonCell.identifier)
        tableView.register(GroupHeaderCell.self, forCellReuseIdentifier: GroupHeaderCell.identifier)
        let tableFooter = UIView()
        tableFooter.backgroundColor = .uiBackground
        tableView.tableFooterView = tableFooter
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchGroup), for: .valueChanged)

        view.addSubview(tableView)
        _ = tableView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)

    }

    private func prepareNavBar() {
        guard let groupName = group?.name else { return }
        self.title = groupName
    }

}

// MARK: - ViewModelDelegate
extension GSRManageGroupController: GSRManageGroupViewModelDelegate {
    func beginBooking() {
        guard let groupName = group?.name else { return }
        let bookingController = GSRLocationsController()
        bookingController.title = "\(groupName) Booking"
        bookingController.group = group
        navigationController?.pushViewController(bookingController, animated: true)
    }

    func inviteToGroup() {
        guard let gid = group?.id else { return }
        let inviteController = GSRGroupInviteViewController()
        inviteController.title = "Invite to Group"
        inviteController.groupID = gid
        inviteController.groupMembers = group?.members
        present(inviteController, animated: true, completion: nil)
    }

    @objc func fetchGroup() {
        guard let gid = group?.id else { return }
        GSRGroupNetworkManager.instance.getGroup(groupid: gid) { (errMessage, group) in
            if let errMessage = errMessage {
                print(errMessage)
            } else if let group = group {
                self.group = group
                self.viewModel.setGroup(group)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
}
