//
//  PrivacyViewController.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

protocol PrivacyViewControllerChangedPreference: AnyObject {
    func changed(option: PrivacyOption, givePermission: Bool)
}

class PrivacyViewController: GenericTableViewController, ShowsAlert, IndicatorEnabled {

    let displayedPrefs = PrivacyOption.visibleOptions

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView = UITableView(frame: .zero, style: .grouped)

        self.title = "Privacy"
        self.registerHeadersAndCells(for: tableView)
        tableView.dataSource = self
        tableView.delegate = self

        tableView.allowsSelection = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
}

// MARK: - Did Change Preference
extension PrivacyViewController: PrivacyViewControllerChangedPreference {
    func changed(option: PrivacyOption, givePermission: Bool) {
        if givePermission && option.requiresAuth {
            // This PrivacyOption requires authentication to give permission.
            if let lastLogin = UserDefaults.standard.getLastLogin(), lastLogin.minutesFrom(date: Date()) <= 10 {
                // Don't ask user to login if it's been less than 10 minutes since last login
                self.changePermission(option: option, givePermission: givePermission)
            } else {
                let llc = LabsLoginController(fetchAllInfo: false, shouldRetrieveRefreshToken: false) { (success) in
                    if success {
                        self.changePermission(option: option, givePermission: givePermission)
                    }
                }
                let nvc = UINavigationController(rootViewController: llc)
                self.present(nvc, animated: true, completion: nil)
            }
        } else {
            self.changePermission(option: option, givePermission: givePermission)
        }
    }

    private func changePermission(option: PrivacyOption, givePermission: Bool) {
        self.showActivity()
        let deadline = DispatchTime.now() + 1
        if givePermission {
            option.givePermission { (success) in
                self.onChangeCompletion(deadline: deadline, success: success)
            }
        } else {
            option.removePermission { (success) in
                self.onChangeCompletion(deadline: deadline, success: success)
            }
        }
    }

    /// Hides activity indicator after deadline has passed. If permision change was not successful, show alert.
    private func onChangeCompletion(deadline: DispatchTime, success: Bool) {
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.hideActivity()
            if !success {
                self.showAlert(withMsg: "Could not save privacy preference. Please make sure you have an internet connection and try again.", title: "Error", completion: {
                    self.tableView.reloadData()
                })
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension PrivacyViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension PrivacyViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return displayedPrefs.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PrivacyTableViewCell.identifier) as! PrivacyTableViewCell

        let option = displayedPrefs[indexPath.section]
        let currentValue = Account.isLoggedIn ? UserDefaults.standard.getPreference(for: option) : false

        cell.setup(with: option, isEnabled: currentValue)
        cell.changePreferenceDelegate = self

        return cell
    }

    func registerHeadersAndCells(for tableView: UITableView) {
        tableView.register(PrivacyTableViewCell.self, forCellReuseIdentifier: PrivacyTableViewCell.identifier)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return displayedPrefs[section].cellFooterDescription
    }
}
