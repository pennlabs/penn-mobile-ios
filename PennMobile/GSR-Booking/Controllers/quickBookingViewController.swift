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
    var quickController: GSRController!

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
    
    let roomLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        label.backgroundColor = .gray
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    fileprivate var barButton: UIBarButtonItem = UIBarButtonItem(title: "Book", style: .done, target: QuickBookingViewController(), action: #selector(quickBook(_:)))
        
    fileprivate func setupDisplay(startSlot: String, endSlot: String, room: GSRRoom, location: GSRLocation) {
        
        roomLabel.text = "Below is the soonest available GSR: \n"
        roomLabel.text = (roomLabel.text ?? "") + "Time Slot: \(startSlot) to \(endSlot) \n"
        roomLabel.text = (roomLabel.text ?? "") + "Room: \(room.roomName) \n"
        roomLabel.text = (roomLabel.text ?? "") + "Location: \(location.name) \n"
        view.addSubview(roomLabel)
        
        NSLayoutConstraint.activate([
            roomLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 130),
            roomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            roomLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            roomLabel.widthAnchor.constraint(equalToConstant: 300),
        ])
        
    }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            setupDropdownButton()
            setupBook()
            setupQuickBooking()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            bookButton.addTarget(self, action: #selector(findGSRButtonPressed), for: .touchUpInside)
        }
        
        @objc func findGSRButtonPressed() {
            setupDisplay(startSlot: soonestStartTimeString, endSlot: soonestEndTimeString, room: soonestRoom, location: soonestLocation)
        }
        
        func setupQuickBooking() {
            for location in locations {
                GSRNetworkManager.instance.getAvailability(lid: location.lid, gid: location.gid, startDate: nil) { [self] result in
                    switch result {
                    case .success(let rooms):
                        startingLocation = location
                        allRooms = rooms
                        getSoonestTimeSlot()
                    case .failure:
                        present(toast: .apiError)
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
    
//    extension QuickBookingViewController: GSRBookable {
//        
//        @objc fileprivate func quickBook(_ sender: Any) {
//            if Account.isLoggedIn {
//                submitBooking(for: GSRBooking(gid: soonestLocation.gid, startTime: soonesTimeSlot.startTime, endTime: soonesTimeSlot.endTime, id: soonestRoom.id, roomName: soonestRoom.roomName))
//            } else {
//                let alertController = UIAlertController(title: "Login Error", message: "Please login to book GSRs", preferredStyle: .alert)
//                
//                alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {_ in }))
//                alertController.addAction(UIAlertAction(title: "Login", style: .default, handler: { _ in
//                    let llc = LabsLoginController { (_) in
//                        DispatchQueue.main.async { [self] in
//                            submitBooking(for: GSRBooking(gid: soonestLocation.gid, startTime: soonesTimeSlot.startTime, endTime: soonesTimeSlot.endTime, id: soonestRoom.id, roomName: soonestRoom.roomName))
//                        }
//                    }
//                    
//                    let nvc = UINavigationController(rootViewController: llc)
//                    
//                    self.present(nvc, animated: true, completion: nil)
//                }))
//                
//                present(alertController, animated: true, completion: nil)
//            }
//        }
//    }
