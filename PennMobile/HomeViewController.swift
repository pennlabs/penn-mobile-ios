//
//  HomeViewController.swift
//  PennMobile
//
//  Created by Victor Chien on 11/19/16.
//  Copyright © 2016 PennLabs. All rights reserved.
//

import UIKit

protocol Refreshable {
    func refreshData(callback: @escaping (_ success: Bool) -> ())
}

@objc class HomeViewController: UITableViewController {
    
    var customSettings = ["Weather", "Schedule", "Study Room Booking", "Dining"]
    var diningHalls = ["1920 Commons", "English House", "Tortas Frontera", "New College House"]
    
    var weather = Weather(temperature: "43", description: "Sunny")
    
    let cellSpacingHeight: CGFloat = 80
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Home"
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor(r: 192, g: 57, b:  43)
        
        //slide out menu stuff
        let revealController = SWRevealViewController()
        revealController.panGestureRecognizer()
        revealController.tapGestureRecognizer()
        
        //Assigns function to the menu button
        let revealButtonItem = UIBarButtonItem(image: UIImage(named: "reveal-icon.png")!, style: .plain, target: revealController, action: #selector(SWRevealViewController.revealToggle(_:)))
        self.navigationItem.leftBarButtonItem = revealButtonItem
        
        let image = UIImage(named: "homepage-settings")
        navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: image, color: UIColor(r: 100, g: 100, b:  100), target: self, action: #selector(handleShowSettings))
        
        //Table View
        
        registerCells()
        
        tableView.tableFooterView = UIView() //removes the lines between blank cells
        
        //enables refresh on pulldown
        refreshControl = UIRefreshControl()
        refreshControl?.isEnabled = true
        refreshControl?.addTarget(self, action: #selector(refreshAllData), for: .valueChanged)
        refreshControl?.backgroundColor = .clear
        refreshControl?.tintColor = .black
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        tableView.addSubview(refreshControl!)
        
        refreshAllData(refreshControl!)
    }
    
    let weatherCell = "weatherCell"
    let agendaCell = "agendaCell"
    let reservationCell = "reservationCell"
    let diningCell = "diningCell"
    
    func registerCells() {
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
            return 600
        } else {
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //adding table view cell programmatically
        let setting = customSettings[indexPath.section]
        if setting == "Weather" {
            let cell = tableView.dequeueReusableCell(withIdentifier: weatherCell, for: indexPath) as! WeatherCell
            cell.delegate = self
            return cell
        } else if setting == "Schedule" {
            let cell = tableView.dequeueReusableCell(withIdentifier: agendaCell, for: indexPath) as! AgendaCell
            //fill in stuff
            cell.delegate = self
            return cell
        } else if setting == "Study Room Booking" {
            let cell = tableView.dequeueReusableCell(withIdentifier: reservationCell, for: indexPath) as! ReservationCell
            //fill in stuff
            cell.backgroundColor = .red
            return cell
        } else if setting == "Dining" {
            let cell = tableView.dequeueReusableCell(withIdentifier: diningCell, for: indexPath) as! DiningCell
            cell.delegate = self
            return cell
        } else {
            return UITableViewCell()
        }
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
    
}

extension HomeViewController: DiningHallDelegate {
    
    internal func goToDiningHallMenu(for hall: String) {
        print(hall)
    }
    
    //returns array of strings of dining halls
    internal func getDiningHallArray() -> [String] {
        return diningHalls
    }
    
}

extension HomeViewController: WeatherDelegate {
    
    internal func getWeather() -> Weather {
        return weather
    }
}

extension HomeViewController: AgendaDelegate {
    
    internal func getAnnouncement() -> String? {
        return "Advanced Registration begins in 3 days"
    }
}

extension HomeViewController: SettingsViewControllerDelegate {
    internal func updateHomeViewController(settings: [String], diningHalls: [String]) {
        self.customSettings = settings
        self.diningHalls = diningHalls
        tableView.reloadData()
    }

    internal func getSelectedSettings() -> [String] {
        return customSettings
    }

    internal func getSelectedDiningHalls() -> [String] {
        return diningHalls
    }
}
