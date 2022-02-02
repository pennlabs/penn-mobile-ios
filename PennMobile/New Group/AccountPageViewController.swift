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

    var profileInfo: [(text: String, info: String)] = []
    var educationInfo: [(text: String, info: String)] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        guard Account.isLoggedIn else {
            self.showAlert(withMsg: "Please login to use this feature", title: "Login Error", completion: { self.navigationController?.popViewController(animated: true)})
            return
        }
        setupTableView()
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
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        tableView.delegate = self
        tableView.dataSource = self
    }

    func setupProfileInfo() {
        guard let firstName = account.first, let lastName = account.last else {
            return
        }
        profileInfo.append((text: "Name", info: "\(firstName) \(lastName)"))
        profileInfo.append((text: "Username", info: account.pennkey))

        guard let email = account.email else {
            return
        }
        profileInfo.append((text: "Email", info: email))
    }

    func setupEducationInfo() {
        guard let degrees = account.degrees else {
            return
        }
        var majorsSet = Set<String>()
        var schoolsSet = Set<String>()
        var gradTerm = String()
        for degree in degrees {
            let majors = degree.majors
            schoolsSet.insert(degree.schoolName)
            for major in majors {
                majorsSet.insert(major.name)
            }
            gradTerm = degree.expectedGradTerm
        }
        educationInfo.append((text: "Graduation Term", info: gradTerm))
        educationInfo.append((text: "School", info: Array(schoolsSet).joined(separator: ", ")))
        educationInfo.append((text: "Major", info: Array(majorsSet).joined(separator: ", ")))
        if schoolsSet.count > 1 {
            educationInfo[1].text += "s"
        }

        if majorsSet.count > 1 {
            educationInfo[2].text += "s"
        }
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
        2
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
