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
    
    let options: [GSRLocation] = GSRLocationModel.shared.getLocations()
    var selectedOption: String?
    var currentLocation: String?
    var currentTime: String = ""
    var currentHour: Int!
    var currentMinute: Int!
    var soonestTimeSlot: Int!
    fileprivate var allRooms = [GSRRoom]()
    var soonestRoom: GSRRoom!

    let locationManager = CLLocationManager()
    var hasReceivedLocationUpdate = false
    
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
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        bookButton.addTarget(self, action: #selector(findGSRButtonPressed), for: .touchUpInside)
    
    }
    
    @objc func findGSRButtonPressed() {
        getCurrentTime()
        setupLocationManager()
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
        
        for option in options {
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
//    
//    func getSoonestTimeSlot(startTime: Int) {
//        let roomsWithTimeSlots = allRooms.filter { $0.availability.count > 0 }
//        var currentRooms = [GSRRoom]()
//        for room in allRooms {
//            let timeSlots = room.availability.filter {
//                return $0.startTime >= startTime
//            }
//
//            var filteredRoom = room
//            filteredRoom.availability = timeSlots
//            if !timeSlots.isEmpty {
//                currentRooms.append(filteredRoom)
//            }
//        }
//        self.soonestRoom = currentRooms.first
//    }
    
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
