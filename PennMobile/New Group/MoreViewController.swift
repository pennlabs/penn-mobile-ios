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
        tableView.register(LinkCell.self, forCellReuseIdentifier: "link")
    }
}

extension MoreViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return ControllerModel.shared.moreOrder.count
        }
        return LinkModel.shared.links.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderViewCell()
        if (section == 0) {
            headerView.setUpView(title: "FEATURES")
        } else {
            headerView.setUpView(title: "RESOURCES")
        }
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "more") as! MoreCell
            cell.backgroundColor = .white
            cell.setUpView(page: ControllerModel.shared.moreOrder[indexPath.row], icon: ControllerModel.shared.moreIcons[indexPath.row])
            setUpAccecories(for: cell)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "link") as! LinkCell
            cell.backgroundColor = .white
            cell.setUpView(link: LinkModel.shared.links[indexPath.row])
            setUpAccecories(for: cell)
            return cell
        }
    }
    
    private func setUpAccecories(for cell: UITableViewCell) {
        let separatorHeight = CGFloat(2)
        let customSeparator = UIView(frame: CGRect(x: 0, y: cell.frame.size.height + 3 + separatorHeight, width: UIScreen.main.bounds.width, height: separatorHeight))
        customSeparator.backgroundColor = UIColor(red:0.96, green:0.97, blue:0.97, alpha:1.0)
        cell.addSubview(customSeparator)
        cell.accessoryType = .disclosureIndicator
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            let targetController = ControllerModel.shared.viewController(for: ControllerModel.shared.moreOrder[indexPath.row])
            navigationController?.pushViewController(targetController, animated: true)
        } else {
            UIApplication.shared.open(LinkModel.shared.links[indexPath.row].url, options: [:])
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
