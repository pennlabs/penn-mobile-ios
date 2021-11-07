//
//  AccountPageViewController.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 9/26/21.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class ProfilePageViewController: UIViewController, ShowsAlertForError {
    var account: Account!
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let picker = UIImagePickerController()
    var viewModel: ProfilePageViewModel!
    
    var profileInfo: [(text: String, info: String)] = []
    var educationInfo: [(text: String, info: String)] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        guard Account.isLoggedIn else {
            self.showAlert(withMsg: "Please login to use this feature", title: "Login Error", completion: { self.navigationController?.popViewController(animated: true)} )
            return
        }
        //account.imageUrl = "https://i.imgur.com/i271XGY.jpg"
        setupPickerController()
        setupViewModel()
        setupTableView()
    }
    
    func setupPickerController() {
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        
    }
    
    func setupViewModel() {
        viewModel = ProfilePageViewModel()
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
        picker.delegate = viewModel
        
        viewModel.delegate = self
    }
    
    func setupView() {
        self.title = "Account"
        view.backgroundColor = .uiGroupedBackground
    }
    func setupTableView() {
        view.addSubview(tableView)
        tableView.register(ProfilePageTableViewCell.self, forCellReuseIdentifier: ProfilePageTableViewCell.identifier)
        tableView.register(ProfilePictureTableViewCell.self, forCellReuseIdentifier: ProfilePictureTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
    }
}

extension ProfilePageViewController: ProfilePageViewModelDelegate {
    func presentImagePicker() {
        present(picker, animated: true)
    }
    func presentTableView(isMajors: Bool) {
        let targetController = InfoTableViewController()
        targetController.isMajors = isMajors
        navigationController?.pushViewController(targetController, animated: true)
    }
    func imageSelected(_ image: UIImage) {
        if let cell = tableView.cellForRow(at: .init(row: 0, section: 0)) as? ProfilePictureTableViewCell {
            cell.profilePicImage = image
            
        }
    }
}
