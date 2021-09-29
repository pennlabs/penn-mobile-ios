//
//  AccountPageViewController.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 9/26/21.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class AccountPageViewController: UIViewController, ShowsAlertForError, UITableViewDelegate, UITableViewDataSource {
    var account: Account!
    var titleLabel = UILabel()
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    var descriptionLabel = UILabel()
    let textList = ["Name", "Username", "Email"]
    var infoList = ["", "", ""]
    let nameView = UIView()
    let usernameView = UIView()
    let emailView = UIView()
    var viewList: [UIView] {
        return [nameView, usernameView, emailView]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Account"
        view.backgroundColor = .uiGroupedBackground
        account = Account.getAccount()
        
        
        if !Account.isLoggedIn {
            self.showAlert(withMsg: "Please login to use this feature", title: "Login Error", completion: { self.navigationController?.popViewController(animated: true)} )
            return
        }
        setupTitleLabel()
        setupTableView()
        setupDescriptionLabel()
        setupInfo()
        setupCellViews()
    }
    
    func setupTitleLabel() {
        titleLabel.text = "PROFILE"
        titleLabel.textColor = .labelSecondary
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.80).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: 1).isActive = true
        tableView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 140).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupDescriptionLabel() {
        descriptionLabel.text = "If your information is incorrect, please send an email to contact@pennclubs.com detailing your issue."
        descriptionLabel.textColor = .labelSecondary
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        descriptionLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.80).isActive = true
        descriptionLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    func setupInfo() {
        guard let firstName = account.first, let lastName = account.last else {
            return
        }
        infoList[0] = "\(firstName) \(lastName)"
        infoList[1] = (account.pennkey)
        guard let email = account.email else {
            return
        }
        infoList[2] = email
        
    }
    
    func setupCellViews() {
        for i in 0..<viewList.count {
            let cellTitleLabel = UILabel.init(frame: CGRect(x:0,y:0,width:100,height:20))
            cellTitleLabel.text = textList[i]
            viewList[i].addSubview(cellTitleLabel)
            cellTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            cellTitleLabel.centerYAnchor.constraint(equalTo: viewList[i].centerYAnchor).isActive = true
            cellTitleLabel.leadingAnchor.constraint(equalTo: viewList[i].leadingAnchor, constant: 20).isActive = true
            cellTitleLabel.heightAnchor.constraint(equalTo: viewList[i].heightAnchor).isActive = true
            let infoLabel = UILabel()
            infoLabel.text = infoList[i]
            viewList[i].addSubview(infoLabel)
            infoLabel.translatesAutoresizingMaskIntoConstraints = false
            infoLabel.centerYAnchor.constraint(equalTo: viewList[i].centerYAnchor).isActive = true
            infoLabel.trailingAnchor.constraint(equalTo: viewList[i].trailingAnchor, constant: -20).isActive = true
            infoLabel.heightAnchor.constraint(equalTo: viewList[i].heightAnchor).isActive = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let whichView = viewList[indexPath.row]
        cell.addSubview(whichView)
        whichView.translatesAutoresizingMaskIntoConstraints = false
        whichView.heightAnchor.constraint(equalTo: cell.heightAnchor, multiplier: 0.5).isActive = true
        whichView.widthAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
        whichView.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
        whichView.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        cell.selectionStyle = .none
        cell.backgroundColor = .uiGroupedBackgroundSecondary
        return cell
    }
}
