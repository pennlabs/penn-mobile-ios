//
//  CourseAlertController.swift
//  PennMobile
//
//  Created by Raunaq Singh on 10/25/20
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class CourseAlertController: GenericViewController, ShowsAlertForError, IndicatorEnabled {

    fileprivate var alerts = [CourseAlert]() {
        didSet {
            alerts.sort(by: { $0.updatedAt > $1.updatedAt })
            alerts.sort(by: { $0.isActive && !$1.isActive })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    fileprivate var tableView: UITableView!
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate var manageSettingsView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Penn Course Alert"
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if Account.isLoggedIn {
            if UserDefaults.standard.getPreference(for: .pennCourseAlerts) {
                manageSettingsView.isHidden = true
                tableView.isHidden = false
            } else {
                fetchAlerts()
                manageSettingsView.isHidden = false
                tableView.isHidden = true
            }
        } else {
            self.showAlert(withMsg: "Please login to use this feature", title: "Login Error", completion: { self.navigationController?.popViewController(animated: true)})
        }
    }

    @objc func fetchAlerts() {
        CourseAlertNetworkManager.instance.getRegistrations { (registrations) in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                if let registrations = registrations {
                    self.alerts = registrations
                }
            }
        }
    }
}

// MARK: - UI Functions
extension CourseAlertController {
    fileprivate func setupUI() {
        setupTableView()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchAlerts), for: .valueChanged)
        setupManageSettingsPage()
    }

    fileprivate func setupTableView() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        view.addSubview(tableView)
        _ = tableView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)

        tableView.register(CourseAlertCell.self, forCellReuseIdentifier: CourseAlertCell.identifier)
        tableView.register(CourseAlertCreateCell.self, forCellReuseIdentifier: CourseAlertCreateCell.identifier)
        tableView.register(ZeroCourseAlertsCell.self, forCellReuseIdentifier: ZeroCourseAlertsCell.identifier)
    }

    fileprivate func setupManageSettingsPage() {
        view.addSubview(manageSettingsView)
        _ = manageSettingsView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)

        let ohNoLabel = UILabel()
        ohNoLabel.text = "Oh No!"
        ohNoLabel.font = UIFont.alertSettingsWarningFont

        manageSettingsView.addSubview(ohNoLabel)

        ohNoLabel.translatesAutoresizingMaskIntoConstraints = false
        ohNoLabel.centerXAnchor.constraint(equalTo: manageSettingsView.centerXAnchor).isActive = true
        ohNoLabel.centerYAnchor.constraint(equalTo: manageSettingsView.centerYAnchor, constant: -100).isActive = true

        let infoLabel = UILabel()
        infoLabel.text = "To manage Penn Course Alert on Penn Mobile, you must change your contact preferences from SMS to Push Notification (via Penn Mobile).\n\nNotifications through Penn Mobile are faster than SMS alerts and can help unclutter your text messages."
        infoLabel.font = UIFont.secondaryInformationFont
        infoLabel.textColor = .labelSecondary
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        infoLabel.sizeToFit()

        manageSettingsView.addSubview(infoLabel)

        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.centerXAnchor.constraint(equalTo: manageSettingsView.centerXAnchor).isActive = true
        infoLabel.topAnchor.constraint(equalTo: ohNoLabel.bottomAnchor, constant: 15).isActive = true
        infoLabel.widthAnchor.constraint(equalTo: manageSettingsView.widthAnchor, multiplier: 0.85).isActive = true

        let openSettingsButton = UIButton()
        openSettingsButton.setTitle("Manage Alert Settings ➜", for: .normal)
        openSettingsButton.setTitleColor(.baseBlue, for: .normal)
        openSettingsButton.titleLabel?.font =  UIFont.primaryInformationFont
        openSettingsButton.addTarget(self, action: #selector(openSettings(_:)), for: .touchUpInside)

        manageSettingsView.addSubview(openSettingsButton)

        openSettingsButton.translatesAutoresizingMaskIntoConstraints = false
        openSettingsButton.centerXAnchor.constraint(equalTo: manageSettingsView.centerXAnchor).isActive = true
        openSettingsButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 20).isActive = true
    }
}

// MARK: - TableView Functions
extension CourseAlertController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == alerts.count {
            if alerts.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: ZeroCourseAlertsCell.identifier, for: indexPath) as! ZeroCourseAlertsCell
                cell.selectionStyle = .none
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                return cell
            }

            let cell = tableView.dequeueReusableCell(withIdentifier: CourseAlertCreateCell.identifier, for: indexPath) as! CourseAlertCreateCell
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CourseAlertCell.identifier, for: indexPath) as! CourseAlertCell
            cell.selectionStyle = .none
            cell.courseAlert = alerts[indexPath.row]
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == alerts.count {
            if alerts.count == 0 {
                return ZeroCourseAlertsCell.cellHeight
            }
            return CourseAlertCreateCell.cellHeight
        } else {
            return CourseAlertCell.cellHeight
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == alerts.count {
            let controller = CourseAlertCreateController()
            let navigationVC = UINavigationController(rootViewController: controller)
            controller.navigationController?.navigationBar.isHidden = true
            tableView.deselectRow(at: indexPath, animated: true)
            navigationVC.presentationController?.delegate = self
            present(navigationVC, animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if indexPath.row < alerts.count {
            return getSwipeConfig(active: alerts[indexPath.row].isActive, id: "\(alerts[indexPath.row].id)")
        }

        return UISwipeActionsConfiguration(actions: [])

     }

     func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if indexPath.row < alerts.count {
            return getSwipeConfig(active: alerts[indexPath.row].isActive, id: "\(alerts[indexPath.row].id)")
        }

        return UISwipeActionsConfiguration(actions: [])

     }

    func getSwipeConfig(active: Bool, id: String) -> UISwipeActionsConfiguration {
        let resubscribeAction = UIContextualAction(style: .normal, title: "Activate", handler: { (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
            CourseAlertNetworkManager.instance.updateRegistration(id: id, deleted: nil, autoResubscribe: nil, cancelled: nil, resubscribe: true, callback: {(success, _) in
                DispatchQueue.main.async {
                    if success {
                        self.fetchAlerts()
                    }
                }
            })
            success(true)
        })

        resubscribeAction.image = UIImage(systemName: "bell.fill")
        resubscribeAction.backgroundColor = .baseBlue

        let cancelAction = UIContextualAction(style: .normal, title: "Cancel", handler: { (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
            CourseAlertNetworkManager.instance.updateRegistration(id: id, deleted: nil, autoResubscribe: nil, cancelled: true, resubscribe: nil, callback: {(success, _) in
                DispatchQueue.main.async {
                    if success {
                        self.fetchAlerts()
                    }
                }
            })
            success(true)
        })

        cancelAction.image = UIImage(systemName: "bell.slash.fill")

        cancelAction.backgroundColor = .baseBlue

        let deleteAction = UIContextualAction(style: .normal, title: "Delete", handler: { (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
            CourseAlertNetworkManager.instance.updateRegistration(id: id, deleted: true, autoResubscribe: nil, cancelled: nil, resubscribe: nil, callback: {(success, _) in
                DispatchQueue.main.async {
                    if success {
                        self.fetchAlerts()
                    }
                }
            })
            success(true)
        })

        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .baseRed

        if active {
            return UISwipeActionsConfiguration(actions: [deleteAction, cancelAction])
        }

        return UISwipeActionsConfiguration(actions: [deleteAction, resubscribeAction])
    }

}

// MARK: - Other Util. Functions
extension CourseAlertController {
    @objc fileprivate func openSettings(_ sender: UIBarButtonItem) {
        // TODO: Open notification settings
        fatalError("Not implemented")
    }
}

// Refresh view on modal dismissal. Handles the case of changing notification preferences and addition of course
extension CourseAlertController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.viewWillAppear(true)
    }
}

extension UITableView {
    func reloadData(with animation: UITableView.RowAnimation) {
        reloadSections(IndexSet(integersIn: 0..<numberOfSections), with: animation)
    }
}
