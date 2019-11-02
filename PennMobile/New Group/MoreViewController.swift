//
//  MoreViewController.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 3/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class MoreViewController: GenericTableViewController, ShowsAlert {
    
    var student: Student?
    
    fileprivate var barButton: UIBarButtonItem!
    
    private var shouldShowProfile: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if shouldShowProfile {
            student = Student.getStudent()
        }
        setUpTableView()
        self.tableView.isHidden = true
        
        let isLoggedIn = UserDefaults.standard.getAccountID() != nil
        barButton = UIBarButtonItem(title: isLoggedIn ? "Logout" : "Login", style: .done, target: self, action: #selector(handleLoginLogout(_:)))
        barButton.tintColor = UIColor.navigation
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldShowProfile {
            let student = Student.getStudent()
            if self.student != student {
                self.student = student
                tableView.reloadData()
            }
        }
    }
    
    override func setupNavBar() {
        self.tabBarController?.title = "More"
        let isLoggedIn = UserDefaults.standard.getAccountID() != nil
        barButton = UIBarButtonItem(title: isLoggedIn ? "Logout" : "Login", style: .done, target: self, action: #selector(handleLoginLogout(_:)))
        barButton.tintColor = UIColor.navigation
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = barButton
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topSpace:CGFloat?
        if #available(iOS 11.0, *) {
            topSpace = self.view.safeAreaInsets.top
        } else {
            topSpace = self.topLayoutGuide.length
        }
        if let topSpace = topSpace, topSpace > 0 {
            self.tableView.isHidden = false
        }
    }
    
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.uiGroupedBackground
        tableView.separatorStyle = .singleLine
        tableView.register(AccountCell.self, forCellReuseIdentifier: "account")
        tableView.register(MoreCell.self, forCellReuseIdentifier: "more")
    }
    
    fileprivate struct PennLink {
        let title: String
        let url: String
    }
    
    fileprivate let pennLinks: [PennLink] = [
        PennLink(title: "Penn Labs", url: "https://pennlabs.org"),
        PennLink(title: "Penn Homepage", url: "https://upenn.edu"),
        PennLink(title: "CampusExpress", url: "https://prod.campusexpress.upenn.edu"),
        PennLink(title: "Canvas", url: "https://canvas.upenn.edu"),
        PennLink(title: "PennInTouch", url: "https://pennintouch.apps.upenn.edu"),
        PennLink(title: "PennPortal", url: "https://portal.apps.upenn.edu/penn_portal")]
    
}

extension MoreViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3//student == nil ? 2 : 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = [1, ControllerModel.shared.moreOrder.count, pennLinks.count]
//        let index = student == nil ? section + 1 : section
//        return rows[index]
        return rows[section]
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderViewCell()
        let titles = ["ACCOUNT", "FEATURES", "LINKS"]
//        let index = student == nil ? section + 1 : section
        headerView.setUpView(title: titles[section])
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let student = student {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "account") as? AccountCell {
                    cell.backgroundColor = .uiGroupedBackgroundSecondary
                    cell.student = student
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "more") as? MoreCell {
                    cell.setUpView(with: "Edit your profile")
                    cell.backgroundColor = .uiGroupedBackgroundSecondary
                    cell.accessoryType = .disclosureIndicator
                    return cell
                }
            }
        } else if indexPath.section == 1 {//(student == nil ? 0 : 1) {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "more") as? MoreCell {
                cell.setUpView(with: ControllerModel.shared.moreOrder[indexPath.row], icon: ControllerModel.shared.moreIcons[indexPath.row])
                cell.backgroundColor = .uiGroupedBackgroundSecondary
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        } else if indexPath.section == 2 {//(student == nil ? 1 : 2) {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "more") as? MoreCell {
                cell.backgroundColor = .uiGroupedBackgroundSecondary
                cell.setUpView(with: pennLinks[indexPath.row].title)
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50//(student != nil && indexPath.section == 0) ? AccountCell.cellHeight : 50
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50//(student != nil && indexPath.section == 0) ? AccountCell.cellHeight : 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let targetController = GSRLoginController()
            targetController.shouldShowSuccessMessage = true
            targetController.shouldShowCancel = false
            targetController.message = "This information is used when booking GSRs and when displaying your name on the homepage."
            navigationController?.pushViewController(targetController, animated: true)
        } else if indexPath.section == 1 { //}(student == nil ? 0 : 1) {
            let targetController = ControllerModel.shared.viewController(for: ControllerModel.shared.moreOrder[indexPath.row])
            navigationController?.pushViewController(targetController, animated: true)
        } else if indexPath.section == 2 {//(student == nil ? 1 : 2) {
            if let url = URL(string: pennLinks[indexPath.row].url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }    
}

// MARK: - Login/Logout
extension MoreViewController {
    @objc fileprivate func handleLoginLogout(_ sender: Any) {
        let isLoggedIn = UserDefaults.standard.getAccountID() != nil
        if isLoggedIn {
            let alertController = UIAlertController(title: "Are you sure?", message: "Please confirm that you wish to logout.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
                DispatchQueue.main.async {
                    AppDelegate.shared.rootViewController.switchToLogout()
                }
            }))
            present(alertController, animated: true, completion: nil)
        } else {
            let lwc = LoginWebviewController()
            lwc.loginCompletion = loginCompletion(_:)
            let nvc = UINavigationController(rootViewController: lwc)
            present(nvc, animated: true, completion: nil)
        }
    }
    
    func loginCompletion(_ successful: Bool) {
        if successful {
            if shouldShowProfile {
                self.student = Student.getStudent()
                tableView.reloadData()
            }
            
            // Clear cache so that home title updates with new first name
            guard let homeVC = ControllerModel.shared.viewController(for: .home) as? HomeViewController else {
                return
            }
            homeVC.clearCache()
        } else {
            showAlert(withMsg: "Something went wrong. Please try again.", title: "Uh oh!", completion: nil)
        }
    }
}
