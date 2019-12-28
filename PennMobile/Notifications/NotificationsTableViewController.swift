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

class NotificationViewController: GenericTableViewController, ShowsAlert {
    
    var userPrefs = UserDefaults.standard.getNotificationPreferences()
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
        var prefs = userPrefs ?? NotificationPreferences()
        prefs[option] = toValue
        UserDefaults.standard.save(prefs)
        self.userPrefs = UserDefaults.standard.getNotificationPreferences()
        showAlert(withMsg: " ", title: "\(option.cellTitle ?? "") \(toValue ? "enabled" : "disabled")", completion: nil)
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
        let currentValue = userPrefs?[option] ?? false
        
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