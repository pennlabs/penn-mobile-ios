//
//  MoreViewController.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 3/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class MoreViewController: GenericTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "More"
        setUpTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "More"
    }
    
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        //tableView.register(AccountCell.self, forCellReuseIdentifier: "account")
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
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? ControllerModel.shared.moreOrder.count : pennLinks.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderViewCell()
        /*if (section == 0) {
            headerView.setUpView(title: "ACCOUNT")
        } else {
            headerView.setUpView(title: "FEATURES")
        }*/
        section == 0 ? headerView.setUpView(title: "FEATURES") : headerView.setUpView(title: "LINKS")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*if (indexPath.section == 0) {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "account") as? AccountCell {
                cell.backgroundColor = .white
                cell.setUpView(avatar: #imageLiteral(resourceName: "franklin"), username: "Benjamin Franklin")
                return cell
            }
        } else if (indexPath.section == 1) {*/
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "more") as? MoreCell {
                cell.backgroundColor = .white
                cell.setUpView(with: ControllerModel.shared.moreOrder[indexPath.row], icon: ControllerModel.shared.moreIcons[indexPath.row])
                let separatorHeight = CGFloat(2)
                let customSeparator = UIView(frame: CGRect(x: 0, y: cell.frame.size.height + 3 + separatorHeight, width: UIScreen.main.bounds.width, height: separatorHeight))
                customSeparator.backgroundColor = UIColor(red:0.96, green:0.97, blue:0.97, alpha:1.0)
                cell.addSubview(customSeparator)
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "more") as? MoreCell {
                cell.backgroundColor = .white
                cell.setUpView(with: pennLinks[indexPath.row].title)
                let separatorHeight = CGFloat(2)
                let customSeparator = UIView(frame: CGRect(x: 0, y: cell.frame.size.height + 3 + separatorHeight, width: UIScreen.main.bounds.width, height: separatorHeight))
                customSeparator.backgroundColor = UIColor(red:0.96, green:0.97, blue:0.97, alpha:1.0)
                cell.addSubview(customSeparator)
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let targetController = ControllerModel.shared.viewController(for: ControllerModel.shared.moreOrder[indexPath.row])
            navigationController?.pushViewController(targetController, animated: true)
        } else if indexPath.section == 1 {
            if let url = URL(string: pennLinks[indexPath.row].url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
}
