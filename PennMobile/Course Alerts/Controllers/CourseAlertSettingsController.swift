//
//  CourseAlertSettingsController.swift
//  PennMobile
//
//  Created by Raunaq Singh on 11/3/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//
//
import Foundation
import UIKit


protocol CourseAlertSettingsChangedPreference: AnyObject {
    func allowChange() -> Bool
    func changed(option: PCAOption, toValue: Bool)
    func requestChange(option: PCAOption, toValue: Bool)
}
//
//class CourseAlertSettingsController: GenericTableViewController, ShowsAlert, IndicatorEnabled, NotificationRequestable {
//
//    let displayedSettings = PCAOption.visibleOptions
//
//    var notificationsEnabled = true
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.tableView = UITableView(frame: .zero, style: .grouped)
//
//        self.title = "Settings"
//        self.registerHeadersAndCells(for: tableView)
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.allowsSelection = false
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        tableView.reloadData()
//
//        #if !targetEnvironment(simulator)
//        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
//            if settings.authorizationStatus == .notDetermined || settings.authorizationStatus == .denied {
//                DispatchQueue.main.async {
//                    // Notification access not granted. Turn off all settings.
//                    self.notificationsEnabled = false
//                    self.tableView.reloadData()
//                }
//            }
//        })
//        #endif
//    }
//}
//
//// MARK: - Did Change Preference
//
//extension CourseAlertSettingsController: CourseAlertSettingsChangedPreference {
//    func requestChange(option: PCAOption, toValue: Bool) {
//
//        if Account.isLoggedIn {
//            requestNotification { (granted) in
//                DispatchQueue.main.async {
//                    if granted {
//                        self.notificationsEnabled = true
//                        self.changed(option: option, toValue: toValue)
//                        self.tableView.reloadData()
//                    }
//                }
//            }
//        } else {
//            self.showAlert(withMsg: "You must log in to access this feature.", title: "Login Required", completion: nil)
//        }
//
//    }
//
//    func allowChange() -> Bool {
//        return Account.isLoggedIn && notificationsEnabled
//    }
//
//    func changed(option: PCAOption, toValue: Bool) {
//
//        UserDefaults.standard.set(option, to: toValue)
//        UserDefaults.standard.set(.pennCourseAlerts, to: toValue)
//
//        CourseAlertNetworkManager.instance.updatePushNotifSettings(pushNotif: toValue, callback: {(success, response, error) in
//            DispatchQueue.main.async {
//                if success {
//                    self.showAlert(withMsg: "\(option.cellTitle ?? "") \(toValue ? "enabled" : "disabled")", title: "Preference Saved", completion: nil)
//                } else if !response.isEmpty {
//                    self.showAlert(withMsg: "Could not save preference. Please make sure you have an internet connection and try again.", title: "Error", completion: {
//                        UserDefaults.standard.set(option, to: !toValue)
//                        UserDefaults.standard.set(.pennCourseAlerts, to: !toValue)
//                        self.tableView.reloadData()
//                    })
//                }
//            }
//        })
//
//    }
//
//}
//
//// MARK: - UITableViewDataSource
//extension CourseAlertSettingsController {
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return displayedSettings.count
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: CourseAlertSettingsCell.identifier) as! CourseAlertSettingsCell
//
//        let option = displayedSettings[indexPath.section]
//        let currentValue: Bool = Account.isLoggedIn && notificationsEnabled ? UserDefaults.standard.getPreference(for: option) : false
//        cell.setup(with: option, isEnabled: currentValue)
//        cell.delegate = self
//        cell.contentView.isUserInteractionEnabled = false
//
//        return cell
//    }
//
//    func registerHeadersAndCells(for tableView: UITableView) {
//        tableView.register(CourseAlertSettingsCell.self, forCellReuseIdentifier: CourseAlertSettingsCell.identifier)
//    }
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 64.0
//    }
//
//    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return displayedSettings[section].cellFooterDescription
//    }
//}
