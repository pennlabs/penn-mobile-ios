//
//  HomeViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/4/17.
//  Copyright © 2016 PennLabs. All rights reserved.
//

import UIKit

@objc class HomeViewController: GenericTableViewController {
    
    //cell identifiers
    internal let weatherCell = "Weather"
    internal let agendaCell = "Schedule"
    internal let reservationCell = "Study Room Booking"
    internal let diningCell = "Dining"
    
    //The cells or widgets that appear in Home Controller in order that they appear
    lazy var customSettings: [String] = {
        return [self.weatherCell, self.agendaCell, self.reservationCell, self.diningCell]
    }()
    
    //Dining Halls for Dining Cell
    var diningHalls: [DiningHall]!
    
    //Events for Agenda Cell
    var events: [Event] = {
        let event1 = Event(name: "LGST101", location: "SHDH 211", startTime: Time(hour: 8, minutes: 0, isAm: true), endTime: Time(hour: 9, minutes: 0, isAm: true))
        
        let event2 = Event(name: "MEAM101", location: "TOWN 101", startTime: Time(hour: 9, minutes: 0, isAm: true), endTime: Time(hour: 11, minutes: 0, isAm: true))
        
        let event3 = Event(name: "FNAR264", location: "FSHR 203", startTime: Time(hour: 11, minutes: 0, isAm: true), endTime: Time(hour: 12, minutes: 0, isAm: false))
        
        let event4 = Event(name: "MATH240", location: "HUNT 250", startTime: Time(hour: 11, minutes: 0, isAm: true), endTime: Time(hour: 3, minutes: 0, isAm: false))
        
        let event5 = Event(name: "GSWS101", location: "WILL 027", startTime: Time(hour: 1, minutes: 0, isAm: false), endTime: Time(hour: 2, minutes: 0, isAm: false))
        
        let event6 = Event(name: "CIS160", location: "MOOR 100", startTime: Time(hour: 7, minutes: 0, isAm: true), endTime: Time(hour: 2, minutes: 0, isAm: false))
        
        let event7 = Event(name: "PennQuest", location: "Houston Hall", startTime: Time(hour: 8, minutes: 30, isAm: true), endTime: Time(hour: 10, minutes: 30, isAm: true))
        
        return [event1, event2, event3, event4, event5, event6, event7]
    }()
    
    //Weather for weather cell
    var weather = Weather(temperature: "43", description: "Sunny")
    
    //Study spaces for Reservation Cell, given in order that they appear in cell
    var studySpaces: [StudyLocation] = {
        let location1: StudyLocation = {
            var location = StudyLocation(name: "Education Commons")
            location.loadGSRs(for: [229, 221, 250])
            return location
        }()
        
        let location2: StudyLocation = {
            var location = StudyLocation(name: "Van Pelt Library")
            location.loadGSRs(for: [229, 221, 250])
            return location
        }()
        
        return [location1, location2]
    }()
    
    //Announcement for Agenda Cell
    var showAgendaAnnouncement: Bool = false
    var agendaAnnouncement: String? = "Advanced Registration begins in 3 days"
    
    //Spacing between cells
    let cellSpacingHeight: CGFloat = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Home"
        
        let image = UIImage(named: "homepage-settings")
        navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: image, color: UIColor(r: 100, g: 100, b:  100), target: self, action: #selector(handleShowSettings))
        
        //Table View
        
        registerCells()
        
        tableView.separatorStyle = .none //removes the separator lines between cells
        tableView.showsVerticalScrollIndicator = false //removes the scroll bar
        
        //enables refresh on pulldown
        refreshControl = UIRefreshControl()
        refreshControl?.isEnabled = true
        refreshControl?.addTarget(self, action: #selector(refreshAllData), for: .valueChanged)
        refreshControl?.backgroundColor = .clear
        refreshControl?.tintColor = .black
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        tableView.addSubview(refreshControl!)
        
        refreshAllData(refreshControl!)
        
        //Default settings for dining halls
        diningHalls = generateDiningHalls(for: ["1920 Commons", "English House", "Tortas Frontera", "New College House"])
        
    }
    
    private func registerCells() {
        tableView.register(WeatherCell.self, forCellReuseIdentifier: weatherCell)
        tableView.register(DiningCell.self, forCellReuseIdentifier: diningCell)
        tableView.register(AgendaCell.self, forCellReuseIdentifier: agendaCell)
        tableView.register(ReservationCell.self, forCellReuseIdentifier: reservationCell)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let setting = customSettings[indexPath.section]
        if setting == "Weather" {
            return 300.0
        } else if setting == "Dining" {
            //return 0.603 * UIScreen.main.bounds.width
            return DiningCell.calculateCellHeight(numberOfCells: diningHalls.count)
        } else if setting == "Schedule" {
            return AgendaCell.calculateHeightForEvents(for: events)
        } else if setting == "Study Room Booking" {
            return ReservationCell.calculateCellHeight(numberOfLocations: 2)
        } else {
            return 60.0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //adding table view cell programmatically
        let setting = customSettings[indexPath.section]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: setting, for: indexPath)
        
        if let cell = cell as? WeatherCell {
            cell.delegate = self
            cell.reloadData()
            return cell
        } else if let cell = cell as? AgendaCell {
            cell.delegate = self
            cell.reloadData()
            return cell
        } else if let cell = cell as? ReservationCell {
            cell.delegate = self
            cell.reloadData()
            return cell
        } else if let cell = cell as? DiningCell {
            cell.delegate = self
            cell.reloadData()
            return cell
        }
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return customSettings.count
    }
    
    // Set the spacing between sections
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else if customSettings[section - 1] == "Weather" {
            return 20
        }
        return cellSpacingHeight
    }
    
    // Make the background color show through
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func handleShowSettings() {
        let svc = SettingsViewController()
        svc.delegate = self
        navigationController?.pushViewController(svc, animated: false)
    }
    
    func refreshAllData(_ refreshControl: UIRefreshControl) {
        NetworkManager.getWeatherData(callback: { (dictionary) in
            
            if let temp = dictionary["temp"] as? NSNumber, let description = dictionary["description"] as? String {
                self.weather = Weather(temperature: temp.stringValue, description: description)
            }
            
            //TODO: Implement other getters
            
            let when = DispatchTime.now() + 0.6
            DispatchQueue.main.asyncAfter(deadline: when, execute: {
                refreshControl.endRefreshing()
                self.tableView.reloadData()
            })
            
            print(self.weather.temperature)
        })
        
    }
    
    internal func generateDiningHalls(for diningHalls: [String]) -> [DiningHall] {
        var arr = [DiningHall]()
        for hall in diningHalls {
            arr.append(DiningHall(name: hall, timeRemaining: getTimeRemainingForDiningHall(for: hall)))
        }
        return arr
    }
    
    //TODO sync up the API
    internal func getTimeRemainingForDiningHall(for hall: String) -> Int {
        if hall == "1920 Commons" {
            return 30
        } else if hall == "English House" {
            return 55
        } else if hall == "Tortas Frontera"{
            return 0
        } else if hall == "New College House" {
            return 0
        } else {
            return 120
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor(r: 192, g: 57, b:  43)
    }
    
}

extension HomeViewController: DiningCellDelegate {
    internal func handleMenuPressed(for diningHall: DiningHall) {
        print(diningHall.name)
    }
    
    internal func getDiningHalls() -> [DiningHall] {
        return diningHalls
    }
}

extension HomeViewController: WeatherDelegate {
    
    internal func getWeather() -> Weather {
        return weather
    }
}

extension HomeViewController: AgendaDelegate {
    
    //returns nil if no announcement is
    internal func getAnnouncement() -> String? {
        return agendaAnnouncement
    }
    
    internal func showAnnouncement() -> Bool {
        return showAgendaAnnouncement
    }
    
    internal func getEvents() -> [Event] {
        return events
    }
}

extension HomeViewController: ReservationCellDelegate {
    
    internal func getStudyLocations() -> [StudyLocation] {
        return studySpaces
    }
    
    //TODO: implement
    internal func handleReserve(for gsr: GSR) {
        print(gsr.description)
    }
    
    //TODO: implement
    internal func handleMore() {
        print("More study spaces")
    }
}

extension HomeViewController: SettingsViewControllerDelegate {
    internal func updateHomeViewController(settings: [String], diningHalls: [String]) {
        self.customSettings = settings
        self.diningHalls = generateDiningHalls(for: diningHalls)
        if !events.isEmpty {
            events.removeLast()
        }
        
        tableView.reloadData()
    }

    internal func getSelectedSettings() -> [String] {
        return customSettings
    }

    internal func getSelectedDiningHalls() -> [String] {
        var arr = [String]()
        for diningHall in diningHalls {
            arr.append(diningHall.name)
        }
        return arr
    }
}
