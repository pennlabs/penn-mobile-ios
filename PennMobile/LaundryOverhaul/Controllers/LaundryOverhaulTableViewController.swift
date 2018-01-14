//
//  LaundryOverhaulTableViewController.swift
//  PennMobile
//
//  Created by Dominic Holmes on 9/30/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

class LaundryOverhaulTableViewController: GenericTableViewController, IndicatorEnabled, ShowsAlert {
    
    internal var halls = [LaundryHall]()
    
    fileprivate let laundryCell = "laundryCell"
    fileprivate let addLaundryCell = "addLaundry"
    
    fileprivate var allowGraphsToAnimate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = nil
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        self.title = "Laundry"
        
        halls = LaundryHall.getPreferences()
        
        registerHeadersAndCells()
        prepareRefreshControl()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(handleEditPressed))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showActivity()
        updateInfo {
            self.hideActivity()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.allowGraphsToAnimate = true
    }
}

// Mark: Add/edit selection
extension LaundryOverhaulTableViewController {
    @objc fileprivate func handleEditPressed() {
        let hallSelectionVC = HallSelectionViewController()
        hallSelectionVC.delegate = self
        hallSelectionVC.chosenHalls = halls //provide selected ids here
        let nvc = UINavigationController(rootViewController: hallSelectionVC)
        showDetailViewController(nvc, sender: nil)
    }
}

// Mark: UIRefreshControl
extension LaundryOverhaulTableViewController {
    fileprivate func prepareRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
    }
    
    @objc fileprivate func handleRefresh(_ sender: Any) {
        updateInfo {
            self.refreshControl?.endRefreshing()
        }
    }
}

//Mark: Set up table view
extension LaundryOverhaulTableViewController {
    fileprivate func registerHeadersAndCells() {
        tableView.register(LaundryCell.self, forCellReuseIdentifier: laundryCell)
        tableView.register(AddLaundryCell.self, forCellReuseIdentifier: addLaundryCell)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return min(halls.count + 1, 3)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.halls.count > indexPath.section {
            let room = halls[indexPath.section]
            let cell = tableView.dequeueReusableCell(withIdentifier: laundryCell) as! LaundryCell
            cell.room = room
            cell.delegate = self
            if allowGraphsToAnimate {
                cell.reloadGraphData()
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: addLaundryCell) as! AddLaundryCell
            cell.delegate = self
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Use for cards 1/2 the size of the screen
        //return self.view.layoutMarginsGuide.layoutFrame.height / 2.0
        // Use for cards 1/2 the size of the iPhone 7 screen
        
        /*
        if let cell = tableView.cellForRow(at: indexPath) as? LaundryCell {
            if cell.isExpanded {
                return 500.0
            }
        }*/
        return 380.0
    }
}

// Laundry API Calls
extension LaundryOverhaulTableViewController {
    func updateInfo(completion: @escaping () -> Void) {
        if halls.isEmpty {
            self.tableView.reloadData()
            completion()
        } else {
            LaundryAPIService.instance.getHalls(for: halls) { (newHalls) in
                if let newHalls = newHalls {
                    self.halls = newHalls
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        completion()
                    }
                } else {
                    DispatchQueue.main.async {
                        completion()
                        self.showAlert(withMsg: "Failed to connect to the API. Please re-check your connection and try again.", title: "Uh oh!", completion: nil)
                    }
                }
            }
        }
    }
}

// Mark: Hall Selection Delegate
extension LaundryOverhaulTableViewController: HallSelectionDelegate {
    func saveSelection(for halls: [LaundryHall]) {
        LaundryHall.setPreferences(for: halls)
        self.halls = halls
        self.tableView.reloadData()
    }
}

// Mark: Laundry Cell Delegate
extension LaundryOverhaulTableViewController: LaundryCellDelegate {
    internal func deleteLaundryCell(for hall: LaundryHall) {
        let message = "Are you sure you want to remove this room from your preferences? You can always add it back later."
        let alert = UIAlertController(title: "Remove Room",
                                      message: message,
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler:{ (UIAlertAction) in
            self.delete(hall: hall)
        }))
        present(alert, animated: true)
    }
    
    private func delete(hall: LaundryHall) {
        if let index = halls.index(of: hall) {
            halls.remove(at: index)
            LaundryHall.setPreferences(for: halls)
            //            tableView.beginUpdates()
            //            self.tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .top)
            //            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
            //            self.tableView.deleteRows(at: [IndexPath(row: 0, section: 1)], with: .top)
            //            self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .bottom)
            //            tableView.endUpdates()
            tableView.reloadData()
        }
    }
}

//Mark: Add Laundry Cell Delegate
extension LaundryOverhaulTableViewController: AddLaundryCellDelegate {
    internal func addPressed() {
        handleEditPressed()
    }
}
