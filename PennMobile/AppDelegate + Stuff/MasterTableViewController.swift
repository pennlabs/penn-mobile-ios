//
//  MasterTableViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 5/3/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class MasterTableViewController: UITableViewController {
    
    private let viewControllerArray: [UIViewController] = [DiningViewController(), BookViewController(), LaundryTableViewController(), NewsViewController(), SupportTableViewController(), AboutViewController()]
    private let displayNameArray = ["Dining", "Study Room Booking", "Laundry", "News", "Emergency", "About"]
    
    private let cellID = "cellID"
    private var selectedIndex = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView() //removes empty lines
        tableView.bounces = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        revealViewController().frontViewController.view.isUserInteractionEnabled = false
        revealViewController().view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        revealViewController().frontViewController.view.isUserInteractionEnabled = true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewControllerArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = displayNameArray[indexPath.row]
        cell.backgroundColor = .clear
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isHighlighted = true
        
        if indexPath == selectedIndex {
            revealViewController().setFrontViewPosition(FrontViewPosition.left, animated: true)
            return
        }
        
        let navController = UINavigationController(rootViewController: viewControllerArray[indexPath.row])
        revealViewController().pushFrontViewController(navController, animated: true)
        
        tableView.cellForRow(at: selectedIndex)?.isHighlighted = false
        selectedIndex = indexPath
    }
}
