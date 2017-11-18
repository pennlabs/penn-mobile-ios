//
//  LaundryTableViewController.swift
//  PennMobile
//
//  Created by Dominic Holmes on 9/30/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

class LaundryOverhaulTableViewController: GenericTableViewController, IndicatorEnabled, ShowsAlert {
    
    internal var halls = [LaundryHall]()
    
    fileprivate let laundryCell = "laundryCell"
    fileprivate let addLaundryCell = "addLaundry"
    
    fileprivate var timer: Timer?
    
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
        
        // Start indicator if there are cells that need to be loaded
        if !halls.isEmpty {
            showActivity()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInfo {
            self.hideActivity()
        }
    }
    
    fileprivate func reloadCellsButNotTable() {
        for cell in self.tableView.visibleCells {
            if let laundryCell = cell as? LaundryCell {
                laundryCell.reloadCollectionViews()
            }
        }
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
        return 300.0
    }
}

// Laundry API Calls
extension LaundryOverhaulTableViewController {
    func updateInfo(completion: @escaping () -> Void) {
        timer?.invalidate()
        if halls.isEmpty {
            self.tableView.reloadData()
            completion()
        } else {
            LaundryAPIService.instance.getHalls(for: halls) { (newHalls) in
                if let newHalls = newHalls {
                    self.halls = newHalls

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.resetTimer()
                        completion()
                    }
                } else {
                    DispatchQueue.main.async {
                        completion()
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
        self.showActivity()
    }
}

// Mark: Laundry Cell Delegate
extension LaundryOverhaulTableViewController: LaundryCellDelegate {
    internal func deleteLaundryCell(for hall: LaundryHall) {
        // Uncomment to show show alert before deletion
        
//        let message = "Are you sure you want to remove this room from your preferences? You can always add it back later."
//        let alert = UIAlertController(title: "Remove Room",
//                                      message: message,
//                                      preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alert.addAction(cancelAction)
//        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler:{ (UIAlertAction) in
//            self.delete(hall: hall)
//        }))
//        present(alert, animated: true)
        
        self.delete(hall: hall)
    }
    
    private func delete(hall: LaundryHall) {
        if let index = halls.index(of: hall) {
            halls.remove(at: index)
            LaundryHall.setPreferences(for: halls)
            tableView.reloadData()
        }
    }

    func handleMachineCellTapped(for hall: LaundryHall, isWasher: Bool, timeRemaining: Int, _ updateCellIfNeeded: @escaping () -> Void) {
        if hall.isUnderNotification(isWasher: isWasher, timeRemaining: timeRemaining) {
            
            LaundryNotificationCenter.shared.removeOutstandingNotification(for: hall, isWasher: isWasher, timeRemaining: timeRemaining) {
                
                hall.updateUnderNotification(completion: {
                    DispatchQueue.main.async {
                        updateCellIfNeeded()
                    }
                })
            }
            
        } else {
            
            LaundryNotificationCenter.shared.notifyWithMessage(for: hall, isWasher: isWasher, in: timeRemaining, title: "Ready!", message: "The \(isWasher ? "washer" : "dryer") has finished running.", completion: { (success) in
                
                if success {
                    hall.updateUnderNotification(completion: {
                        DispatchQueue.main.async {
                            updateCellIfNeeded()
                        }
                    })
                }
            })
        }
    }
}

//Mark: Add Laundry Cell Delegate
extension LaundryOverhaulTableViewController: AddLaundryCellDelegate {
    internal func addPressed() {
        handleEditPressed()
    }
}

// Mark: Timer
extension LaundryOverhaulTableViewController {
    internal func resetTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (_) in
            if self.halls.filter({ (hall) -> Bool in
                return hall.numDryerRunning > 0 || hall.numWasherRunning > 0
            }).count == 0 {
                self.timer?.invalidate()
                return
            }
            
            LaundryNotificationCenter.shared.removeExpiredNotifications()

            for hall in self.halls {
                hall.decrementMinutesRemaining()
            }
            
            self.reloadCellsButNotTable()
        })
    }
}
