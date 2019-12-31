//
//  PrivacyViewController.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

protocol PrivacyViewControllerChangedPreference: class {
    func changed(option: PrivacyOption, toValue: Bool)
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
    func changed(option: PrivacyOption, toValue: Bool) {
        // Save change to local storage (user defaults)
        UserDefaults.standard.set(option, to: toValue)
        
        // Upload change to the Penn Mobile server. If this fails, reverse the change.
        self.showActivity()
        let deadline = DispatchTime.now() + 1
        UserDBManager.shared.saveUserPrivacySettings { (success) in
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.hideActivity()
                if success {
//                    self.showAlert(withMsg: "\(option.cellTitle) \(toValue ? "enabled" : "disabled")", title: "Preference Saved", completion: nil)
                } else {
                    // Couldn't save change to the server
                    self.showAlert(withMsg: "Could not save privacy preference. Please make sure you have an internet connection and try again.", title: "Error", completion: {
                        // Reverse the change, if we couldn't connect to the server
                        UserDefaults.standard.set(option, to: !toValue)
                        self.tableView.reloadData()
                    })
                }
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
