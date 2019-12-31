//
//  NotificationsTableViewController.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

protocol NotificationViewControllerChangedPreference: class {
    func changed(option: NotificationOption, toValue: Bool)
}

class NotificationViewController: GenericTableViewController, ShowsAlert, IndicatorEnabled {
    
    let displayedPrefs = NotificationOption.visibleOptions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: .zero, style: .grouped)
        
        self.title = "Notifications"
        self.registerHeadersAndCells(for: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.allowsSelection = false
    }
}

// MARK: - Did Change Preference
extension NotificationViewController: NotificationViewControllerChangedPreference {
    func changed(option: NotificationOption, toValue: Bool) {
        // Save change to local storage (user defaults)
        UserDefaults.standard.set(option, to: toValue)
        
        // Upload change to the Penn Mobile server. If this fails, reverse the change.
        self.showActivity()
        UserDBManager.shared.saveUserNotificationSettings { (success) in
            DispatchQueue.main.async {
                self.hideActivity()
                if success ?? false {
                    self.showAlert(withMsg: "\(option.cellTitle ?? "") \(toValue ? "enabled" : "disabled")", title: "Preference Saved", completion: nil)
                } else {
                    // Couldn't save change to the server
                    self.showAlert(withMsg: "Could not save notification preference. Please make sure you have an internet connection and try again.", title: "Error", completion: {
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
extension NotificationViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NotificationViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return displayedPrefs.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier) as! NotificationTableViewCell
        
        let option = displayedPrefs[indexPath.section]
        let currentValue = UserDefaults.standard.getPreference(for: option)
        
        cell.setup(with: option, isEnabled: currentValue)
        cell.changePreferenceDelegate = self
        
        return cell
    }
    
    func registerHeadersAndCells(for tableView: UITableView) {
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.identifier)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return displayedPrefs[section].cellFooterDescription
    }
}
