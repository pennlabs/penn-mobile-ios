//
//  quickBookingViewController.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 10/5/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import UIKit
import CoreLocation

class QuickBookingViewController: UIViewController, CLLocationManagerDelegate {
    
    let locations: [GSRLocation] = GSRLocationModel.shared.getLocations()
    fileprivate var selectedOption: String?
    fileprivate var currentLocation: String?
    
    fileprivate var currentTime: String = ""
    fileprivate var currentHour: Int!
    fileprivate var currentMinute: Int!
    
    fileprivate var startingLocation: GSRLocation!
    fileprivate var soonestTimeSlot: String!
    fileprivate var soonestRoom: GSRRoom!
    fileprivate var soonestLocation: GSRLocation!
    fileprivate var min: Date! = Date.distantFuture
    
    fileprivate var newGSRView: GSRViewModel!
    fileprivate var newController: GSRController!
    fileprivate var allRooms: [GSRRoom]!
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate var hasReceivedLocationUpdate = false
    
//    var min: Date {
//        //round up to half hour
//    }
    
    let dropdownButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose a not preferred GSR", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let bookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Find GSR", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupDropdownButton()
        setupBook()
        setupViewModel()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        bookButton.addTarget(self, action: #selector(findGSRButtonPressed), for: .touchUpInside)
    }
    
    @objc func findGSRButtonPressed() {
        
    }
    
    func setupViewModel() {
        for location in locations {
            startingLocation = location
            newGSRView = GSRViewModel(selectedLocation: startingLocation)
            GSRNetworkManager.instance.getAvailability(lid: location.lid, gid: location.gid, startDate: currentTime) { result in
                switch result {
                case .success(let rooms):
                    self.allRooms = rooms
                    self.newGSRView.updateData(with: rooms)
                    self.getSoonestTimeSlot()
                case .failure:
                    self.present(toast: .apiError)
                }
            }
        }
    }
    
    func setupDropdownButton() {
        view.addSubview(dropdownButton)
        dropdownButton.addTarget(self, action: #selector(showDropdown), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            dropdownButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dropdownButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dropdownButton.widthAnchor.constraint(equalToConstant: 300),
            dropdownButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func showDropdown() {
        let alertController = UIAlertController(title: "Choose an option", message: nil, preferredStyle: .actionSheet)
        
        for option in locations {
            alertController.addAction(UIAlertAction(title: option.name, style: .default, handler: { [weak self] _ in
                self?.selectedOption = option.name
                self?.dropdownButton.setTitle(option.name, for: .normal) // Update button title
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func setupBook() {
        view.addSubview(bookButton)
        
        NSLayoutConstraint.activate([
            bookButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            bookButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bookButton.widthAnchor.constraint(equalToConstant: 200),
            bookButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func getCurrentTime() {
        let current = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        currentTime = formatter.string(from: current)
        let hourMinuteArray = currentTime.components(separatedBy: ":")
        currentHour = Int(hourMinuteArray[0])
        currentMinute = Int(hourMinuteArray[1])
        print(currentTime)
        print(currentHour!)
        print(currentMinute!)
    }
    
    func getSoonestTimeSlot() {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        for room in allRooms {
            guard let availability = room.availability.first(where: { $0.startTime >= Date() }) else {
                continue
            }

            let startTime = availability.startTime

            if startTime < min {
                min = startTime
                soonestTimeSlot = formatter.string(from: min)
                soonestRoom = room
                soonestLocation = startingLocation
            }
        }
    }
    
    func setupLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if hasReceivedLocationUpdate { return }
        hasReceivedLocationUpdate = true
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        currentLocation = String(format: "%.6f, %.6f", latitude, longitude)
        print("\(currentLocation ?? "current location unavailable")")
        locationManager.stopUpdatingLocation()
        hasReceivedLocationUpdate = false
    }
}
