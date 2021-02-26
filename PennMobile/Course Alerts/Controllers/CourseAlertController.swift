//
//  CourseAlertController.swift
//  PennMobile
//
//  Created by Raunaq Singh on 10/25/20
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

class CourseAlertController: GenericViewController {
    
    fileprivate var alerts = [CourseAlert]() {
        didSet {
            alerts.sort(by: { $0.updatedAt > $1.updatedAt })
            alerts.sort(by: { $0.isActive && !$1.isActive })
            DispatchQueue.main.async {
                self.updateMainView()
            }
        }
    }
    
    fileprivate var tableView: UITableView!
    fileprivate var createAlert: ButtonWithImage!
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate var loadingView: UIActivityIndicatorView!
    
    fileprivate lazy var alertSettings: UIBarButtonItem = {
        if #available(iOS 13.0, *) {
            return UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(openSettings(_:)))
        } else {
            return UIBarButtonItem(image: UIImage(named: "settings"), style: .done, target: self, action: #selector(openSettings(_:)))
        }
    }()
    
    fileprivate var manageSettingsView = UIView()
    fileprivate var loginView = UIView()
    
    fileprivate var enabled = false {
        didSet {
            DispatchQueue.main.async {
                self.updateMainView()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Penn Course Alert"
        navigationItem.rightBarButtonItem = alertSettings
        
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loginView.isHidden = Account.isLoggedIn
        manageSettingsView.isHidden = true
        tableView.isHidden = true
        alertSettings.isEnabled = Account.isLoggedIn
        
        setupLoadingView()
        startLoadingViewAnimation()
        
        if !Account.isLoggedIn {
            stopLoadingViewAnimation()
        }
        
        fetchAlerts()
        fetchSettings()
        
    }
    
}

// MARK: - Fetch Functions

extension CourseAlertController: FetchPCADataProtocol {
    
    @objc func fetchAlerts() {
        CourseAlertNetworkManager.instance.getRegistrations { (registrations) in
            if let registrations = registrations {
                self.alerts = registrations
                DispatchQueue.main.async {
                    if(self.tableView != nil){
                        self.refreshControl.endRefreshing()
                        self.tableView.reloadData(with: .automatic)
                    }
                }
            }
        }
    }
    
    func fetchSettings() {
        CourseAlertNetworkManager.instance.getSettings { (settings) in
            if let settings = settings {
                self.enabled = settings.profile.pushNotifications
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
        setupLoginPage()
    }
    
    func setupLoadingView() {
        loadingView = UIActivityIndicatorView(style: .whiteLarge)
        loadingView.color = .black
        loadingView.isHidden = false
        view.addSubview(loadingView)
        loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingView.translatesAutoresizingMaskIntoConstraints = false
    }

    func startLoadingViewAnimation() {
        if loadingView != nil && !loadingView.isHidden {
            loadingView.startAnimating()
        }
    }

    func stopLoadingViewAnimation() {
        if loadingView != nil && !loadingView.isHidden {
            loadingView.isHidden = true
            loadingView.stopAnimating()
        }
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
        
        manageSettingsView.backgroundColor = .white
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

        
        manageSettingsView.isHidden = true
    }
    
    fileprivate func setupLoginPage() {
        
        loginView.backgroundColor = .white
        view.addSubview(loginView)
        _ = loginView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        let noAlertsLabel = UILabel()
        noAlertsLabel.text = "Log in to Use This Feature."
        noAlertsLabel.font = UIFont.avenirMedium
        noAlertsLabel.textColor = .lightGray
        
        loginView.addSubview(noAlertsLabel)
        
        noAlertsLabel.translatesAutoresizingMaskIntoConstraints = false
        noAlertsLabel.centerXAnchor.constraint(equalTo: loginView.centerXAnchor).isActive = true
        noAlertsLabel.centerYAnchor.constraint(equalTo: loginView.centerYAnchor, constant: -50).isActive = true
        
        loginView.isHidden = true
    }

}

// MARK: - TableView Functions

extension CourseAlertController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == alerts.count {
            if (alerts.count == 0) {
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
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == alerts.count {
            if (alerts.count == 0) {
                return ZeroCourseAlertsCell.cellHeight
            }
            return CourseAlertCreateCell.cellHeight
        } else {
            return CourseAlertCell.cellHeight
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == alerts.count {
            let controller = CourseAlertAddController()
            controller.delegate = self
            let navigationVC = UINavigationController(rootViewController: controller)
            controller.navigationController?.navigationBar.isHidden = true
            tableView.deselectRow(at: indexPath, animated: true)
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
        let resubscribeAction = UIContextualAction(style: .normal, title:  "Activate", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            CourseAlertNetworkManager.instance.updateRegistration(id: id, deleted: nil, autoResubscribe: nil, cancelled: nil, resubscribe: true, callback: {(success, error) in
                DispatchQueue.main.async {
                    if success {
                        self.fetchAlerts()
                    }
                }
            })
            success(true)
        })
        if #available(iOS 13.0, *) {
            resubscribeAction.image = UIImage(systemName: "bell.fill")
        } else {
            resubscribeAction.image = UIImage(named: "bell")
        }
        resubscribeAction.backgroundColor = .baseBlue
        
        let cancelAction = UIContextualAction(style: .normal, title:  "Cancel", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            CourseAlertNetworkManager.instance.updateRegistration(id: id, deleted: nil, autoResubscribe: nil, cancelled: true, resubscribe: nil, callback: {(success, error) in
                DispatchQueue.main.async {
                    if success {
                        self.fetchAlerts()
                    }
                }
            })
            success(true)
        })
        if #available(iOS 13.0, *) {
            cancelAction.image = UIImage(systemName: "bell.slash.fill")
        } else {
            cancelAction.image = UIImage(named: "bell")
        }
        cancelAction.backgroundColor = .baseBlue
        
        let deleteAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            CourseAlertNetworkManager.instance.updateRegistration(id: id, deleted: true, autoResubscribe: nil, cancelled: nil, resubscribe: nil, callback: {(success, error) in
                DispatchQueue.main.async {
                    if success {
                        self.fetchAlerts()
                    }
                }
            })
            success(true)
        })
        if #available(iOS 13.0, *) {
            deleteAction.image = UIImage(systemName: "trash.fill")
        } else {
            deleteAction.image = UIImage(named: "x_button_selected")
        }
        deleteAction.backgroundColor = .baseRed
     
        if active {
            return UISwipeActionsConfiguration(actions: [deleteAction, cancelAction])
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, resubscribeAction])
    }
    
}

// MARK: - Other Util. Functions

extension CourseAlertController {
    
    func updateMainView() {
        self.startLoadingViewAnimation()
        manageSettingsView.isHidden = enabled
        tableView.isHidden = !enabled
        self.view.bringSubviewToFront(manageSettingsView)
        DispatchQueue.main.async {
            self.stopLoadingViewAnimation()
        }
    }
    
    @objc fileprivate func openSettings(_ sender: UIBarButtonItem) {
        let settingsController = CourseAlertSettingsController()
        self.navigationController?.pushViewController(settingsController, animated: true)
    }
    
    @objc fileprivate func openAddAlertController(_ sender: UITapGestureRecognizer) {
        let controller = CourseAlertAddController()
        controller.delegate = self
        let navigationVC = UINavigationController(rootViewController: controller)
        controller.navigationController?.navigationBar.isHidden = true
        present(navigationVC, animated: true, completion: nil)
    }
    
}


extension UITableView {
    func reloadData(with animation: UITableView.RowAnimation) {
        reloadSections(IndexSet(integersIn: 0..<numberOfSections), with: animation)
    }
}
