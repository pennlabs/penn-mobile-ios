//
//  HomeViewController.swift
//  PennMobile
//
//  Created by Victor Chien on 11/19/16.
//  Copyright © 2016 PennLabs. All rights reserved.
//

import UIKit

@objc class HomeViewController: UITableViewController {
    
    var customSettings = ["Weather", "Schedule", "Study Room Booking", "Dining"]
    var diningHalls = ["1920 Commons", "English House", "Tortas Frontera", "New College House"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkManager.getWeatherData(callback: { (dictionary) in
            
            if let temp = dictionary["temp"] {
                print(temp)
            }
            
            if let description = dictionary["description"] {
                print(description)
            }
            
        })
        
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
        if customSettings[indexPath.row] == "Weather" {
            return 350.0
        } else if customSettings[indexPath.row] == "Dining" {
            //return 0.603 * UIScreen.main.bounds.width
            return DiningCell.calculateCellHeight(numberOfCells: diningHalls.count)
        } else {
            return 100.0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customSettings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //adding table view cell programmatically
        if customSettings[indexPath.row] == "Weather" {
            let cell = tableView.dequeueReusableCell(withIdentifier: weatherCell, for: indexPath) as! WeatherCell
            cell.condition.text = "Sunny"
            cell.temperature.text = "43"
            cell.comment.text = "Bust out the shades"
            cell.weatherImage.image = UIImage(named:"1d.png")
            
            return cell
        } else if customSettings[indexPath.row] == "Schedule" {
            let cell = tableView.dequeueReusableCell(withIdentifier: agendaCell, for: indexPath) as! AgendaCell
            //fill in stuff
            cell.backgroundColor = .blue
            
            return cell
        } else if customSettings[indexPath.row] == "Study Room Booking" {
            let cell = tableView.dequeueReusableCell(withIdentifier: reservationCell, for: indexPath) as! ReservationCell
            //fill in stuff
            cell.backgroundColor = .red
            
            return cell
        } else if customSettings[indexPath.row] == "Dining" {
            let cell = tableView.dequeueReusableCell(withIdentifier: diningCell, for: indexPath) as! DiningCell
            cell.delegate = self
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func handleShowSettings() {
        let svc = SettingsViewController()
        svc.delegate = self
        navigationController?.pushViewController(svc, animated: false)
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
