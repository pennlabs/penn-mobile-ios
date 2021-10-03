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
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    var profileInfo = [(text: "Name", info: " "), (text: "Username", info: " "), (text: "Email", info: " ")]
    var educationInfo = [(text: "Graduation Term", info: " "), (text: "School", info: " "), (text: "Major", info: " ")]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTableView()
        guard Account.isLoggedIn else {
            self.showAlert(withMsg: "Please login to use this feature", title: "Login Error", completion: { self.navigationController?.popViewController(animated: true)} )
            return
        }
        setupProfileInfo()
        setupEducationInfo()
    }
    
    func setupView() {
        self.title = "Account"
        view.backgroundColor = .uiGroupedBackground
        account = Account.getAccount()
    }
    func setupTableView() {
        view.addSubview(tableView)
        tableView.register(ProfilePageTableViewCell.self, forCellReuseIdentifier: ProfilePageTableViewCell.identifier)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupProfileInfo() {
        guard let firstName = account.first, let lastName = account.last else {
            return
        }
        profileInfo[0].info = "\(firstName) \(lastName)"
        profileInfo[1].info = (account.pennkey)
        guard let email = account.email else {
            return
        }
        profileInfo[2].info = email
    }
    
    func setupEducationInfo() {
        guard let degrees = account.degrees else {
            return
        }
        var majorsSet = Set<String>()
        var schoolsSet = Set<String>()
        for degree in degrees {
            let majors = degree.majors
            schoolsSet.insert(degree.schoolName)
            for major in majors {
                majorsSet.insert(major.name)
            }
            educationInfo[0].info = degree.expectedGradTerm
        }
        
        if schoolsSet.count > 1 {
            educationInfo[1].text += "s"
        }
        
        if majorsSet.count > 1 {
            educationInfo[2].text += "s"
        }
        educationInfo[1].info = Array(schoolsSet).joined(separator: ", ")
        educationInfo[2].info = Array(majorsSet).joined(separator: ", ")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return profileInfo.count
        } else {
            return educationInfo.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfilePageTableViewCell.identifier, for: indexPath) as! ProfilePageTableViewCell
            cell.key = profileInfo[indexPath.row].text
            cell.info = profileInfo[indexPath.row].info
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfilePageTableViewCell.identifier, for: indexPath) as! ProfilePageTableViewCell
            cell.key = educationInfo[indexPath.row].text
            cell.info = educationInfo[indexPath.row].info
            cell.selectionStyle = .none
            return cell
        }
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Account.isLoggedIn && account.isStudent ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "PROFILE"
        }
        return "EDUCATION"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "If your information is incorrect, please send an email to contact@pennlabs.org detailing your issue."
        }
        return nil
    }
}
