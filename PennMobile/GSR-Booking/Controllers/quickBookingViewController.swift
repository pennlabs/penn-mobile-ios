//
//  quickBookingViewController.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 10/5/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import UIKit
import CoreLocation

class QuickBookingViewController: UIViewController, CLLocationManagerDelegate, ShowsAlert {
    
    let locations: [GSRLocation] = GSRLocationModel.shared.getLocations()
    fileprivate var selectedOption: String?
    fileprivate var currentLocation: String?
    
    fileprivate var startingLocation: GSRLocation!
    fileprivate var soonestStartTimeString: String!
    fileprivate var soonestEndTimeString: String!
    fileprivate var soonesTimeSlot: GSRTimeSlot!
    fileprivate var soonestRoom: GSRRoom!
    fileprivate var soonestLocation: GSRLocation!
    fileprivate var min: Date! = Date.distantFuture
    
    fileprivate var allRooms: [GSRRoom]!
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate var hasReceivedLocationUpdate = false
    
    let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let unpreferButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pick a location you don't prefer", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let bookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Find GSR", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemPurple
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let roomLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        
    fileprivate func setupDisplay(startSlot: String, endSlot: String, room: GSRRoom, location: GSRLocation) {
        roomLabel.text = """
            Soonest available GSR:
            Time Slot: \(startSlot) to \(endSlot)
            Room: \(room.roomName)
            Location: \(location.name)
            """
        view.addSubview(roomLabel)
        
        NSLayoutConstraint.activate([
            roomLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 180),
            roomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            roomLabel.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUnpreferButton()
        setupBook()
        setupQuickBooking()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        bookButton.addTarget(self, action: #selector(findGSRButtonPressed), for: .touchUpInside)
    }
    
    @objc func findGSRButtonPressed() {
        setupDisplay(startSlot: soonestStartTimeString, endSlot: soonestEndTimeString, room: soonestRoom, location: soonestLocation)
        setupSubmitButton()

    }
    
    func setupQuickBooking() {
        var skip: Bool = false
        for location in locations {
            if !UserDefaults.standard.isInWharton() {
                skip = true
            }
            
            GSRNetworkManager.instance.getAvailability(lid: location.lid, gid: location.gid, startDate: nil) { [self] result in
                switch result {
                case .success(let rooms):
                    if (location.kind == .wharton && skip) || (location.name == selectedOption) {
                        break
                    } else {
                        startingLocation = location
                        allRooms = rooms
                        getSoonestTimeSlot()
                    }
                case .failure:
                    present(toast: .apiError)
                }
            }
        }
    }
    
    func setupSubmitButton() {
        view.addSubview(submitButton)
        submitButton.addTarget(self, action: #selector(quickBook(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 500),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 300),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func setupUnpreferButton() {
        view.addSubview(unpreferButton)
        unpreferButton.addTarget(self, action: #selector(showDropdown), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            unpreferButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            unpreferButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unpreferButton.widthAnchor.constraint(equalToConstant: 300),
            unpreferButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func showDropdown() {
        let alertController = UIAlertController(title: "Choose an option", message: nil, preferredStyle: .actionSheet)
        
        for option in locations {
            alertController.addAction(UIAlertAction(title: option.name, style: .default, handler: { [weak self] _ in
                self?.selectedOption = option.name
                self?.unpreferButton.setTitle(option.name, for: .normal) // Update button title
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
                soonestStartTimeString = formatter.string(from: startTime)
                soonestEndTimeString = formatter.string(from: availability.endTime)
                soonesTimeSlot = availability
                soonestRoom = room
                soonestLocation = startingLocation
            }
        }
    }
}
    
    //        func setupLocationManager() {
    //            if CLLocationManager.locationServicesEnabled() {
    //                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    //                locationManager.startUpdatingLocation()
    //            }
    //        }
    //
    //        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //            guard let location = locations.last else { return }
    //            if hasReceivedLocationUpdate { return }
    //            hasReceivedLocationUpdate = true
    //            let latitude = location.coordinate.latitude
    //            let longitude = location.coordinate.longitude
    //            currentLocation = String(format: "%.6f, %.6f", latitude, longitude)
    //            print("\(currentLocation ?? "current location unavailable")")
    //            locationManager.stopUpdatingLocation()
    //            hasReceivedLocationUpdate = false
    //        }
    //    }

extension QuickBookingViewController: GSRBookable {
    @objc fileprivate func quickBook(_ sender: Any) {
        if !Account.isLoggedIn {
            self.showAlert(withMsg: "You are not logged in!", title: "Error", completion: {self.navigationController?.popViewController(animated: true)})
        } else {
            submitBooking(for: GSRBooking(gid: soonestLocation.gid, startTime: soonesTimeSlot.startTime, endTime: soonesTimeSlot.endTime, id: soonestRoom.id, roomName: soonestRoom.roomName))
        }
    }
}
