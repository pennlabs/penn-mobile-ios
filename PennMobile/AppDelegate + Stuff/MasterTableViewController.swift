//
//  MasterTableViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 5/3/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class ControllerSettings: NSObject {
    
    static let shared = ControllerSettings()
    
    let vcDictionary: [String: UIViewController] = {
        var dict = [String: UIViewController]()
        dict["Dining"] = DiningViewController()
        dict["Study Room Booking"] = BookViewController()
        dict["Laundry"] = LaundryTableViewController()
        dict["News"] = NewsViewController()
        dict["Support"] = ContactsTableViewController()
        dict["About"] = AboutViewController()
        return dict
    }()
    
    var viewControllers: [UIViewController] {
        return displayNames.map { (title) -> UIViewController in
            return vcDictionary[title]!
        }
    }
    
    var displayNames: [String] {
        return UserDefaults.standard.getVCDisplayNames() ??
            ["Dining", "Study Room Booking", "Laundry", "News", "Support", "About"]
    }
    
    func viewController(for title: String) -> UIViewController {
        return vcDictionary[title] ?? UIViewController()
    }
    
    var firstController: UIViewController {
        return viewControllers.first!
    }
    
    func visibleVCIndex() -> IndexPath {
        for vc in viewControllers {
            if vc.isVisible {
                return IndexPath(row: viewControllers.index(of: vc)!, section: 0)
            }
        }
        return IndexPath(row: 0, section: 0)
    }
    
    func visibleVCName() -> String {
        return displayNames[visibleVCIndex().row]
    }
}

class MasterTableViewController: MoveableTableViewController {
    
    fileprivate var viewControllerArray = ControllerSettings.shared.viewControllers
    fileprivate var displayNameArray = ControllerSettings.shared.displayNames
    
    fileprivate let cellID = "cellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTableView()
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
    
    internal override func rowMoved(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        swap(&viewControllerArray[sourceIndexPath.row], &viewControllerArray[destinationIndexPath.row]) //swap controllers
        swap(&displayNameArray[sourceIndexPath.row], &displayNameArray[destinationIndexPath.row]) //swap display names
    }
}

// MARK: setup tableview

extension MasterTableViewController {
    fileprivate func loadTableView() {
        tableView.tableFooterView = UIView() //removes empty lines
        tableView.bounces = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        isMoveable = true //enables moveability
        setFinishedMovingCell {
            UserDefaults.standard.set(vcDisplayNames: self.displayNameArray)
        }
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
        
        if viewControllerArray[indexPath.row].isVisible {
            revealViewController().setFrontViewPosition(FrontViewPosition.left, animated: true)
            return
        }
        
        let navController = UINavigationController(rootViewController: viewControllerArray[indexPath.row])
        revealViewController().pushFrontViewController(navController, animated: true)
        tableView.cellForRow(at: ControllerSettings.shared.visibleVCIndex())?.isHighlighted = false
        DatabaseManager.shared.trackVC(displayNameArray[indexPath.row]) //send screen name to DB
    }
}
