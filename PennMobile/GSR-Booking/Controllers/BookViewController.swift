//
//  BookViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 4/20/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

protocol CollectionViewProtocol: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {}

class BookViewController: GenericViewController, ShowsAlert {
    
    internal var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        ai.activityIndicatorViewStyle = .gray
        ai.hidesWhenStopped = true
        return ai
    }()
    
    internal lazy var pickerView: UIPickerView = {
        let pv = UIPickerView(frame: .zero)
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.delegate = self
        pv.dataSource = self
        return pv
    }()
    
    internal lazy var rangeSlider: RangeSlider = {
        let rs = RangeSlider()
        rs.setMinAndMaxValue(0, maxValue: 100)
        rs.thumbSize = 24.0
        rs.displayTextFontSize = 14.0
        return rs
    }()
    
    internal var earliestTime: Date = Parser.midnight
    internal var endDate: Date = Parser.midnight.tomorrow
    
    internal var minDate: Date = Parser.midnight
    internal var maxDate: Date = Parser.midnight.tomorrow
    
    internal lazy var dates : [GSRDate] = DateHandler.getDates()
    internal lazy var locations : [GSRLocation] = LocationsHandler.getLocations()
    
    internal var locationRoomData = Dictionary<String, [GSRHour]>()
    internal var parsedRoomData = Dictionary<String, [GSRHour]>()
    internal var sortedKeys = [String]()
    
    internal lazy var currentDate : GSRDate = self.dates[0]
    internal lazy var currentLocation : GSRLocation = self.locations[0]
    
    var currentSelection : Set<GSRHour> = Set() {
        didSet {
            refreshLoginLogout()
        }
    }
    
    internal let roomCell = "roomCell"
    internal let cellSize: CGFloat = 100
    
    internal lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        tv.register(RoomCell.self, forCellReuseIdentifier: self.roomCell)
        tv.tableFooterView = UIView()
        return tv
    }()
    
    fileprivate let emptyView: EmptyView = {
        let ev = EmptyView()
        ev.isHidden = true
        return ev
    }()
    
    var storedOffsets = [Int: CGFloat]()

    private lazy var loginLogoutButton: UIBarButtonItem = {
        return UIBarButtonItem(title: self.loginLogoutButtonTitle, style: .done, target: self, action: #selector(handleLoginLogout(_:)))
    }()
    
    // MARK: - View Initialization Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.startAnimating()
        
        self.screenName = "Study Room Booking"
        setupView()
        setupSlider()
        setEarliestTime()
        minDate = earliestTime.localTime
    }
    
    internal func setEarliestTime() {
        if dates.count > 0 && currentDate.compact == dates[0].compact {
            let now = Date()
            let formatter = Parser.formatter
            let strFormat = formatter.string(from: now)
            earliestTime = formatter.date(from: strFormat)!.roundedDownToHour
        } else {
            earliestTime = locationRoomData.firstOpening.roundedDownToHour
        }
    }
    
    private func setupSlider() {
        rangeSlider.setMinValueDisplayTextGetter { (minValue) -> String? in
            return self.locationRoomData.isEmpty ? "" : self.getStringTimeFromValue(minValue)
        }
        rangeSlider.setMaxValueDisplayTextGetter { (maxValue) -> String? in
            return self.locationRoomData.isEmpty ? "" : self.getStringTimeFromValue(maxValue)
        }
        rangeSlider.setValueFinishedChangingCallback { (min, max) in
            let totalMinutes = CGFloat(self.earliestTime.minutesFrom(date: self.endDate))
            let minMinutes = (Int((CGFloat(min) / 100.0) * totalMinutes) / 60) * 60
            let maxMinutes = (Int((CGFloat(max) / 100.0) * totalMinutes) / 60) * 60
            self.minDate = self.earliestTime.add(minutes: minMinutes).localTime.roundedDownToHour
            self.maxDate = self.earliestTime.add(minutes: maxMinutes).localTime.roundedDownToHour
            self.reloadParsedData()
        }
    }
    
    private func getStringTimeFromValue(_ val: Int) -> String? {
        let formatter = Parser.formatter
        let totalMinutes = CGFloat(earliestTime.minutesFrom(date: endDate))
        let minutes = Int((CGFloat(val) / 100.0) * totalMinutes)
        let chosenDate = earliestTime.add(minutes: minutes)
        formatter.amSymbol = "a"
        formatter.pmSymbol = "p"
        formatter.dateFormat = "ha"
        return formatter.string(from: chosenDate)
    }
    
    private func reloadParsedData() {
        self.parsedRoomData = locationRoomData.parse(from: self.minDate, to: self.maxDate)
        self.sortedKeys = self.parsedRoomData.sortedKeys
        setEarliestTime()
        self.currentSelection.removeAll()
        self.showEmptyViewIfNeeded()
        self.tableView.reloadData()
    }
    
    internal var loginLogoutButtonTitle: String {
        get {
            return currentSelection.isEmpty ? isLoggedIn ? "Logout" : "Login" : "Submit"
        }
    }
    
    internal func showEmptyViewIfNeeded() {
        emptyView.isHidden = !parsedRoomData.isEmpty
        tableView.isHidden = parsedRoomData.isEmpty
    }
    
    internal var isLoggedIn: Bool {
        let (email, password) = getEmailAndPassword()
        return email != nil && password != nil
    }
    
    private func setupView() {
        self.title = "Study Room Booking"
        
        view.addSubview(pickerView)
        view.addSubview(tableView)
        view.addSubview(emptyView)
        view.addSubview(rangeSlider)
        
        pickerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = rangeSlider.anchor(pickerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 8, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 30)
        
        _ = tableView.anchor(rangeSlider.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        _ = emptyView.anchor(tableView.topAnchor, left: tableView.leftAnchor, bottom: tableView.bottomAnchor, right: tableView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        navigationItem.rightBarButtonItems = [loginLogoutButton, UIBarButtonItem(customView: activityIndicator)]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dates = DateHandler.getDates()
        setEarliestTime()
        refreshContent()
        
        revealViewController().panGestureRecognizer().delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        revealViewController().panGestureRecognizer().delegate = nil
    }
    
    // MARK: - Data Methods

    func refreshContent() {
        self.activityIndicator.startAnimating()
        
        GSRNetworkManager.shared.getHours(self.currentDate.compact, gid: self.currentLocation.code) {
            (res: AnyObject) in
            
            if (res is NSError) {
                self.showAlert(withMsg: "Can't communicate with the server", title: "Oops", completion: nil)
                self.activityIndicator.stopAnimating()
            } else {
                DispatchQueue.main.async(execute: {
                    self.activityIndicator.stopAnimating()
                    self.locationRoomData = Parser.getAvailableTimeSlots(res as! String)
                    self.endDate = self.locationRoomData.lastOpening.roundedDownToHour
                    self.setEarliestTime()
                    self.rangeSlider.reload()
                    self.reloadParsedData()
                })
            }
        }
    }
    
    // Mark: - Submitting Hours Selection
    
    func submitSelection() {
        if (validateSubmission() == false) {
            showAlert(withMsg: "You can only choose consecutive times", title: "Can't do that.", completion: nil)
        } else {            
            if isLoggedIn {
                let dest = ProcessViewController()
                let ids = getSelectionIds()
                let (email, password) = getEmailAndPassword()
                
                dest.ids = ids
                dest.date = currentDate
                dest.location = currentLocation
                dest.email = email
                dest.password = password
                
                navigationController?.pushViewController(dest, animated: true)
            } else {
                let destination = CredentialsViewController()
                destination.date = currentDate
                destination.ids = [Int]()
                
                for selection in currentSelection {
                    destination.ids!.append(selection.id)
                }
                
                destination.location = currentLocation
                
                let nvc = UINavigationController(rootViewController: destination)
                present(nvc, animated: true, completion: nil)                
            }
        }
    }
    
    internal func handleLoginLogout(_ sender: UIButton) {
        if !currentSelection.isEmpty {
            submitSelection()
        } else if isLoggedIn {
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "email")
            defaults.removeObject(forKey: "password")
            self.refreshLoginLogout()
        } else {
            let destination = CredentialsViewController()
            let nvc = UINavigationController(rootViewController: destination)
            present(nvc, animated: true, completion: nil)
        }
    }
    
    internal func refreshLoginLogout() {
        self.loginLogoutButton.tintColor = .clear
        loginLogoutButton.title = loginLogoutButtonTitle
        self.loginLogoutButton.tintColor = nil
    }
}

// MARK: - Picker view methods

extension BookViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return dates.count
        case 1:
            return locations.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            currentDate = dates[row]
            break
        case 1:
            currentLocation = locations[row]
            break
        default:
            break
        }
        
        refreshContent()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            if (row == 0) {
                return "Today"
            } else if (row == 1) {
                return "Tomorrow"
            }
            return dates[row].compact
        case 1:
            return locations[row].name
        default:
            return ""
        }
    }
}

// MARK: - Table view methods

extension BookViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return parsedRoomData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedKeys[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: roomCell,
                                             for: indexPath)
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? RoomCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forSection: indexPath.section)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   didEndDisplaying cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? RoomCell else { return }
        
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellSize
    }
}

