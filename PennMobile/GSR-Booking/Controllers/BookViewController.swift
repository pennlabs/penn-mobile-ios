//
//  BookViewController.swift
//  GSR
//
//  Created by Yagil Burowski on 15/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import UIKit

protocol ShowsAlert {}

extension ShowsAlert where Self: UIViewController {
    func showAlert(withMsg: String, title: String = "Error", completion: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: withMsg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            if let completion = completion {
                completion()
            }
        }))
        present(alertController, animated: true, completion: nil)
    }
}

protocol CollectionViewProtocol: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {}

class BookViewController: GenericViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, ShowsAlert {
    
    internal var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        ai.activityIndicatorViewStyle = .gray
        ai.hidesWhenStopped = true
        return ai
    }()
    
    // MARK: - Outlets and Properties
    
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
    
    private func getStringTimeFromValue(_ val: Int) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let startDate = earliestDate//formatter.date(from: "12:00am")!
        let totalMinutes = CGFloat((startDate?.minutesFrom(date: endDate))!)
        let minutes = Int((CGFloat(val) / 100.0) * totalMinutes)
        let chosenDate = Date.addMinutes(to: startDate!, minutes: minutes)
        formatter.amSymbol = "a"
        formatter.pmSymbol = "p"
        formatter.dateFormat = "ha"
        return formatter.string(from: chosenDate)
    }
    
    internal var earliestDate: Date!
    
    internal let endDate: Date = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let date = formatter.date(from: "12:00am")
        return Date.addMinutes(to: date!, minutes: 24*60)
    }()
    
    internal var minDate: Date!
    
    internal var maxDate: Date = Parser.getDateFromTime(time: "11:59pm")
    
    internal lazy var dates : [GSRDate] = DateHandler.getDates()
    
    internal lazy var locations : [GSRLocation] = LocationsHandler.getLocations()
    
    internal var roomData = Dictionary<String, [GSRHour]>()
    internal var sortedKeys = [String]()
    
    var currentDate : GSRDate? {
        didSet {
            setEarliestTime()
            rangeSlider.reload()
        }
    }
    
    lazy var currentLocation : GSRLocation? = {
        return self.locations[0]
    }()
    
    var currentSelection : Set<GSRHour>? = Set() {
        didSet {
            refreshLoginLogout()
        }
    }
    
    private let roomCell = "roomCell"
    let cellSize: CGFloat = 100
    
    internal lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        tv.register(RoomCell.self, forCellReuseIdentifier: self.roomCell)
        tv.tableFooterView = UIView()
        return tv
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
        currentDate = dates[0]
        minDate = earliestDate.convertToLocalTime()
    }
    
    internal func setEarliestTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if dates.count > 0 && currentDate?.compact == dates[0].compact {
            let now = Date()
            let strFormat = formatter.string(from: now)
            earliestDate = Date.roundDownToHour(formatter.date(from: strFormat)!)
        } else {
            earliestDate = formatter.date(from: "12:00am")!
        }
    }
    
    private func setupSlider() {
        rangeSlider.setMinValueDisplayTextGetter { (minValue) -> String? in
            return self.getStringTimeFromValue(minValue)
            
        }
        rangeSlider.setMaxValueDisplayTextGetter { (maxValue) -> String? in
            return self.getStringTimeFromValue(maxValue)
        }
        rangeSlider.setValueFinishedChangingCallback { (min, max) in
            self.refreshContent()
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mma"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            let startDate = self.earliestDate!
            let totalMinutes = CGFloat(startDate.minutesFrom(date: self.endDate))
            let minMinutes = (Int((CGFloat(min) / 100.0) * totalMinutes) / 60) * 60
            let maxMinutes = (Int((CGFloat(max) / 100.0) * totalMinutes) / 60) * 60
            self.minDate = Date.addMinutes(to: startDate, minutes: minMinutes).convertToLocalTime()
            self.maxDate = Date.addMinutes(to: startDate, minutes: maxMinutes).convertToLocalTime()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    internal var loginLogoutButtonTitle: String {
        get {
            if !(currentSelection?.isEmpty)! {
                return "Submit"
            }
            return isLoggedIn ? "Logout" : "Login"
        }
    }
    
    internal var isLoggedIn: Bool {
        return UserDefaults.standard.bool(forKey: "logged in")
    }
    
    private func setupView() {
        self.title = "Study Room Booking"
        navigationItem.title = title
        
        view.backgroundColor = .white
        
        view.addSubview(pickerView)
        view.addSubview(tableView)
        view.addSubview(rangeSlider)
        
        pickerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = rangeSlider.anchor(pickerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 8, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 30)
        
        _ = tableView.anchor(rangeSlider.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        navigationItem.rightBarButtonItems = [loginLogoutButton, UIBarButtonItem(customView: activityIndicator)]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dates = DateHandler.getDates()
        setEarliestTime()
        refreshContent()
        
        revealViewController().panGestureRecognizer().delegate = self
    }

    override func awakeFromNib() {
        // init properties
        super.awakeFromNib()
        refreshContent()
    }
    
    // MARK: - Picker view methods
    
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
    
    // MARK: - Table view methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return roomData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(roomData.sortedKeys)[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: roomCell,
                                                               for: indexPath)
        
        return cell
    }
    
    // MARK: - CollectionView Related Methods
    
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
    
    // MARK: - Data Methods

    func refreshContent() {
        self.refreshLoginLogout()
        self.activityIndicator.startAnimating()
        
        if minDate == nil {
            return
        }
        
        GSRNetworkManager.getHours((currentDate?.compact)!, gid: (currentLocation?.code)!) {
            (res: AnyObject) in
            
            if (res is NSError) {
                self.showAlert(withMsg: "Can't communicate with the server", title: "Oops", completion: nil)
                self.activityIndicator.stopAnimating()
            } else {
                DispatchQueue.main.async(execute: {
                    self.activityIndicator.stopAnimating()
                    self.roomData = Parser.getAvailableTimeSlots(res as! String, startDate: self.minDate, endDate: self.maxDate)
                    self.sortedKeys = self.roomData.sortedKeys
                    self.currentSelection?.removeAll()
                    self.tableView.reloadData()
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
                
                for selection in currentSelection! {
                    destination.ids!.append(selection.id)
                }
                
                destination.location = currentLocation
                
                let nvc = UINavigationController(rootViewController: destination)
                present(nvc, animated: true, completion: nil)                
            }
        }
    }
    
    internal func handleLoginLogout(_ sender: UIButton) {
        if !(currentSelection?.isEmpty)! {
            submitSelection()
        } else if isLoggedIn {
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "logged in")
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

