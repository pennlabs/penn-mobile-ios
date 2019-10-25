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
    fileprivate var viewModel: GSRGroupViewModel!
    fileprivate var settings = [String:String]() //TODO: change the type
    
    var group: GSRGroup! //this will be nil until prepareViewModel called (perhaps, make it an optional)
    
    init(group: GSRGroup) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
       super.viewDidLoad()
        prepareUI()
        prepareViewModel(group: group)
    }

    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
        //TODO: potentially update the data again here
    }
}

//MARK: UI Stuff
extension GSRManageGroupController {
    func prepareViewModel(group: GSRGroup) {
        self.group = group
        viewModel = GSRGroupViewModel(group: group)
        viewModel.delegate = self
    }
    
     func prepareUI() {
        prepareNavBar()
        prepareTableView()
    }
    
    private func prepareTableView() {
        tableView = UITableView(frame: .zero)
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
        tableView.register(GroupSettingsCell.self, forCellReuseIdentifier: GroupSettingsCell.identifier)
        tableView.tableFooterView = UIView()

        view.addSubview(tableView)
        _ = tableView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareNavBar() {
        self.title = group.name
    }
    
}

// MARK: - ViewModelDelegate
extension GSRManageGroupController: GSRGroupViewModelDelegate {
    
    //TODO: this may not be neccessary ... delete if so
}
