//
//  NotificationsTableViewController.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

protocol NotificationViewControllerChangedPreference: AnyObject {
    func allowChange() -> Bool
    func changed(option: NotificationOption, toValue: Bool)
    func requestChange(option: NotificationOption, toValue: Bool)
}

class NotificationViewController: GenericTableViewController, ShowsAlert, IndicatorEnabled, NotificationRequestable {

    let displayedPrefs = NotificationOption.visibleOptions

    var notificationsEnabled = true

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView = UITableView(frame: .zero, style: .grouped)

        self.title = "Notifications"
        self.registerHeadersAndCells(for: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()

        CourseAlertNetworkManager.instance.getSettings { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        #if !targetEnvironment(simulator)
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined || settings.authorizationStatus == .denied {
                DispatchQueue.main.async {
                    // Notification access not granted. Turn off all settings.
                    self.notificationsEnabled = false
                    self.tableView.reloadData()
                }
            }
        })
        #endif
    }
}

// MARK: - Did Change Preference
extension NotificationViewController: NotificationViewControllerChangedPreference {
    func requestChange(option: NotificationOption, toValue: Bool) {
        if Account.isLoggedIn {
            requestNotification { (granted) in
                DispatchQueue.main.async {
                    if granted {
                        self.notificationsEnabled = true
                        self.changed(option: option, toValue: toValue)
                        self.tableView.reloadData()
                    }
                }
            }
        } else {
            self.showAlert(withMsg: "You must log in to access this feature.", title: "Login Required", completion: nil)
        }
    }

    func allowChange() -> Bool {
        Account.isLoggedIn && notificationsEnabled
    }

    func changed(option: NotificationOption, toValue: Bool) {
        // Save change to local storage (user defaults)
        UserDefaults.standard.set(option, to: toValue)

        // Upload change to the Penn Mobile server. If this fails, reverse the change.
        self.showActivity()
        let deadline = DispatchTime.now() + 1

        UserDBManager.shared.saveUserNotificationSettings { (success) in
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                if success {
                    // Push to pca backend if changing pca preference
                    if option == .pennCourseAlerts {
                        self.pushPCAPreferenceChange(toValue: toValue)
                    } else {
                        self.hideActivity()
                    }
                } else {
                    // Couldn't save change to the server
                    self.hideActivity()
                    self.showAlert(withMsg: "Could not save notification preference. Please make sure you have an internet connection and try again.", title: "Error", completion: {
                        // Reverse the change, if we couldn't connect to the server
                        UserDefaults.standard.set(option, to: !toValue)
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }

    func pushPCAPreferenceChange(toValue: Bool) {
        CourseAlertNetworkManager.instance.updatePushNotifSettings(pushNotif: toValue, callback: {(success, response, _) in
            DispatchQueue.main.async {
                self.hideActivity()
                if success {
                    UserDefaults.standard.set(.alertsThroughPennMobile, to: toValue)
                } else if !response.isEmpty {
                    self.showAlert(withMsg: "Could not save notification preference. Please make sure you have an internet connection and try again.", title: "Error", completion: {
                        UserDefaults.standard.set(.pennCourseAlerts, to: !toValue)
                        self.tableView.reloadData()
                    })
                }
            }
        })
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
        let currentValue: Bool = Account.isLoggedIn && notificationsEnabled ? UserDefaults.standard.getPreference(for: option) : false

        cell.setup(with: option, isEnabled: currentValue)
        cell.delegate = self
        cell.contentView.isUserInteractionEnabled = false

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
