//
//  MasterTableViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 5/3/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

class MasterTableViewController: MoveableTableViewController, Trackable {
    
    fileprivate var viewControllerArray = ControllerModel.shared.viewControllers
    fileprivate var displayNameArray = ControllerModel.shared.displayNames
    
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
    
    func prepare() {
        trackScreen(ControllerModel.shared.firstPage.rawValue)
    }
}

// MARK: setup tableview
extension MasterTableViewController {
    fileprivate func loadTableView() {
        tableView.tableFooterView = UIView() //removes empty lines
        tableView.bounces = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        //isMoveable = true //enables row moveability
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
        tableView.cellForRow(at: ControllerModel.shared.visibleVCIndex())?.isHighlighted = false
        trackScreen(displayNameArray[indexPath.row])
    }
}

// MARK: - Transitions
extension MasterTableViewController {
    func transition(to page: Page) {
        print(page.rawValue)
    }
}
