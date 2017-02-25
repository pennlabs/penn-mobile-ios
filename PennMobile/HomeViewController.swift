//
//  HomeViewController.swift
//  PennMobile
//
//  Created by Victor Chien on 11/19/16.
//  Copyright © 2016 PennLabs. All rights reserved.
//

import UIKit

protocol DiningHallDelegate {
    func goToDiningHallMenu(for hall: String)
}

@objc class HomeViewController: UITableViewController {
    
    var customSettings = ["Weather", "Schedule", "Study Room Break", "Dining"]
    
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
        self.navigationController?.navigationBar.tintColor = UIColor.blue
        
        //slide out menu stuff
        let revealController = SWRevealViewController()
        revealController.panGestureRecognizer()
        revealController.tapGestureRecognizer()
        
        //Assigns function to the menu button
        let revealButtonItem = UIBarButtonItem(image: UIImage(named: "reveal-icon.png")!, style: .plain, target: revealController, action: #selector(SWRevealViewController.revealToggle(_:)))
        self.navigationItem.leftBarButtonItem = revealButtonItem
        
        //Table View
        
        registerCells()
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
        if indexPath.row == 0 {
            return 350.0
        } else if indexPath.row == 3 {
            return 0.603 * UIScreen.main.bounds.width
        } else {
            return 100.0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //adding table view cell programmatically
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: weatherCell, for: indexPath) as! WeatherCell
            cell.condition.text = "Sunny"
            cell.temperature.text = "43"
            cell.comment.text = "Bust out the shades"
            cell.weatherImage.image = UIImage(named:"1d.png")
            
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: agendaCell, for: indexPath) as! AgendaCell
            //fill in stuff
            cell.backgroundColor = .blue
            
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: reservationCell, for: indexPath) as! ReservationCell
            //fill in stuff
            cell.backgroundColor = .red
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: diningCell, for: indexPath) as! DiningCell
            cell.delegate = self
            return cell
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

extension HomeViewController: DiningHallDelegate {
    
    func goToDiningHallMenu(for hall: String) {
        print(hall)
    }
    
}
