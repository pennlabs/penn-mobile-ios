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

class PrivacyViewController: GenericTableViewController, ShowsAlert {
    
    var userPrefs = UserDefaults.standard.getPrivacyPreferences()
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
}

// MARK: - Did Change Preference
extension PrivacyViewController: PrivacyViewControllerChangedPreference {
    func changed(option: PrivacyOption, toValue: Bool) {
        var prefs = userPrefs ?? PrivacyPreferences()
        prefs[option] = toValue
        UserDefaults.standard.save(prefs)
        self.userPrefs = UserDefaults.standard.getPrivacyPreferences()
        showAlert(withMsg: " ", title: "\(option.cellTitle) \(toValue ? "enabled" : "disabled")", completion: nil)
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
        let currentValue = userPrefs?[option] ?? false
        
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
