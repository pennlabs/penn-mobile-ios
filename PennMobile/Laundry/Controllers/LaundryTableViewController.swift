//
//  LaundryTableViewController.swift
//  PennMobile
//
//  Created by Dominic Holmes on 9/30/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

class LaundryTableViewController: GenericTableViewController, IndicatorEnabled, ShowsAlert, NotificationRequestable {
    
    internal var rooms = [LaundryRoom]()
    
    fileprivate let laundryCell = "laundryCell"
    fileprivate let addLaundryCell = "addLaundry"

    fileprivate var timer: Timer?
    
    internal let allowMachineNotifications = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = nil
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.backgroundColor = .uiBackground
        
        tableView.tableFooterView = getFooterViewForTable()
                
        rooms = LaundryRoom.getPreferences()
        
        registerHeadersAndCells()
        prepareRefreshControl()
        
        // initialize navigation bar

        // Start indicator if there are cells that need to be loaded
        if !rooms.isEmpty {
            showActivity()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInfo {
            self.hideActivity()
            
            // Check if laundry is working
            LaundryAPIService.instance.checkIfWorking { (isWorking) in
                DispatchQueue.main.async {
                    if let isWorking = isWorking, !isWorking {
                        self.tableView.tableHeaderView = self.getHeaderViewForTable()
                        self.navigationVC?.addPermanentStatusBar(text: .laundryDown)
                    }
                }
            }
        }
    }
    
    fileprivate func getFooterViewForTable() -> UIView {
        let v = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 30.0))
        v.backgroundColor = UIColor.clear
        return v
    }
    
    fileprivate func getHeaderViewForTable() -> UIView {
        let v = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 70.0))
        v.backgroundColor = UIColor.clear
        return v
    }
    
    override func setupNavBar() {
        self.tabBarController?.title = "Laundry"
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleEditPressed))
    }
}

// MARK: - Add/edit selection
extension LaundryTableViewController {
    @objc fileprivate func handleEditPressed() {
        let roomselectionVC = RoomSelectionViewController()
        roomselectionVC.delegate = self
        roomselectionVC.chosenRooms = rooms //provide selected ids here
        let nvc = UINavigationController(rootViewController: roomselectionVC)
        showDetailViewController(nvc, sender: nil)
    }
}

// MARK: - UIRefreshControl
extension LaundryTableViewController {
    fileprivate func prepareRefreshControl() {
        refreshControl = UIRefreshControl()
        //refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
    }
    
    @objc fileprivate func handleRefresh(_ sender: Any) {
        updateInfo {
            self.refreshControl?.endRefreshing()
        }
    }
}

//MARK: - Set up table view
extension LaundryTableViewController {
    fileprivate func registerHeadersAndCells() {
        tableView.register(LaundryCell.self, forCellReuseIdentifier: laundryCell)
        tableView.register(AddLaundryCell.self, forCellReuseIdentifier: addLaundryCell)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return min(rooms.count + 1, 3)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.rooms.count > indexPath.section {
            let room = rooms[indexPath.section]
            let cell = tableView.dequeueReusableCell(withIdentifier: laundryCell) as! LaundryCell
            cell.room = room
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: addLaundryCell) as! AddLaundryCell
            cell.delegate = self
            cell.numberOfRoomsSelected = self.rooms.count
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Use for cards 1/2 the size of the screen
        //return self.view.layoutMarginsGuide.layoutFrame.height / 2.0
        
        // Use for cards of fixed size
        if indexPath.section >= rooms.count {
            return 80.0
        } else {
            return 418.0
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section >= rooms.count {
            return 80.0
        } else {
            return 418.0
        }
    }
}

// Laundry API Calls
extension LaundryTableViewController {
    func updateInfo(completion: @escaping () -> Void) {
        timer?.invalidate()
        LaundryNotificationCenter.shared.updateForExpiredNotifications {
            if self.rooms.isEmpty {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    completion()
                }
            } else {
                LaundryAPIService.instance.fetchLaundryData(for: self.rooms) { (rooms) in
                    DispatchQueue.main.async {
                        if let rooms = rooms {
                            self.rooms = rooms
                            self.tableView.reloadData()
                            self.resetTimer()
                        }
                        completion()
                    }
                }
            }
        }
    }
}

// MARK: - room Selection Delegate
extension LaundryTableViewController: RoomSelectionVCDelegate {
    func saveSelection(for rooms: [LaundryRoom]) {
        LaundryRoom.setPreferences(for: rooms)
        LaundryAPIService.instance.fetchLaundryData(for: rooms) { (rooms) in
            DispatchQueue.main.async {
                if let rooms = rooms {
                    self.rooms = rooms
                    self.tableView.reloadData()
                }
            }
        }
        sendUpdateNotification()
    }
}

// MARK: - Laundry Cell Delegate
extension LaundryTableViewController: LaundryCellDelegate {
    internal func deleteLaundryCell(for room: LaundryRoom) {
        if let index = rooms.firstIndex(of: room) {
            rooms.remove(at: index)
            LaundryRoom.setPreferences(for: rooms)
            UserDBManager.shared.saveLaundryPreferences(for: rooms)
            tableView.reloadData()
            sendUpdateNotification()
        }
    }
}

// MARK: - Home Page Notification
extension LaundryTableViewController {
    fileprivate func sendUpdateNotification() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "LaundryUpdateNotification"), object: nil)
    }
}

// MARK: - Add Laundry Cell Delegate
extension LaundryTableViewController: AddLaundryCellDelegate {
    internal func addPressed() {
        handleEditPressed()
    }
}

// MARK: - Timer
extension LaundryTableViewController {
    internal func resetTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (_) in
            if !self.rooms.containsRunningMachine() {
                self.timer?.invalidate()
                return
            }
            
            for room in self.rooms {
                room.decrementTimeRemaining(by: 1)
            }
            
            LaundryNotificationCenter.shared.updateForExpiredNotifications {
                DispatchQueue.main.async {
                    self.reloadVisibleMachineCells()
                }
            }
        })
    }
    
    fileprivate func reloadVisibleMachineCells() {
        for cell in self.tableView.visibleCells {
            if let laundryCell = cell as? LaundryCell {
                laundryCell.reloadData()
            }
        }
    }
}
