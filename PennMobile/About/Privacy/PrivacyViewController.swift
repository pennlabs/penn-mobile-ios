//
//  PrivacyViewController.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit


/*
 
 PrivacyPreferences (Stored in UserDefaults + on the server):
 
 "privacy-share-course": true,
 "privacy-share-transaction": true,
 "privacy-share-school": true
 
 "notification-gsr-booking": true,
 "notification-dining-balance-weekly": true,
 "notification-laundry-done": true,
 */

class PrivacyViewController: GenericTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Privacy"
        
        self.registerHeadersAndCells(for: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func registerHeadersAndCells(for tableView: UITableView) {
        //tableView.register(PreferenceCell.self, forCellReuseIdentifier: FitnessHourCell.identifier)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
