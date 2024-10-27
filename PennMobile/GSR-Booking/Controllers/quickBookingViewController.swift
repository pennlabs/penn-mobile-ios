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
    
    let GSRCoords = [
        (latitude: 39.95346818228411, longitude: -75.19802835987453, title: "Huntsman"),
        (latitude: 39.95127416568136, longitude: -75.19700321676956, title: "Academic Research"),
        (latitude: 39.9498719027302, longitude: -75.1957015032777, title: "Biotech Commons"),
        (latitude: 39.95059135463279, longitude: -75.18936553396598, title: "Education Commons"),
        (latitude: 39.95287694035962, longitude: -75.1934213456054, title: "Weigle"),
        (latitude: 39.94964995704518, longitude: -75.19927449163818, title: "Levin Building"),
        (latitude: 39.952828782832924, longitude: -75.19349473211366, title: "Lippincott"),
        (latitude: 39.95291806251846, longitude: -75.19342134560544, title: "Van Pelt"),
        (latitude: 39.95357192013402, longitude: -75.19463651005043, title: "Perelman Center")
    ]
    
    let mapVC = MapViewController()
    
    let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(UIColor(named: "labelPrimary"), for: .normal)
        button.backgroundColor = UIColor(named: "baseGreen")!
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
        button.setTitle("Preferred Location", for: .normal)
        button.setTitleColor(UIColor(named: "labelPrimary"), for: .normal)
        button.backgroundColor = UIColor(named: "baseLabsBlue")!
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
        button.setTitleColor(UIColor(named: "labelPrimary"), for: .normal)
        button.backgroundColor = UIColor(named: "baseLabsBlue")!
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
        
    let mappingController = GSRMappingController()

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
        setupMapping()
        setupSubmitButton()

    }
    
    func setupMapping() {
        var lat: CLLocationDegrees!
        var long: CLLocationDegrees!
        if let coords = GSRCoords.first(where: { $0.title == soonestLocation.name }) {
            lat = coords.latitude
            long = coords.longitude
        }
        mappingController.destinationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

        addChild(mappingController)

        view.addSubview(mappingController.view)
        
        mappingController.view.layer.cornerRadius = 10
        mappingController.view.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        mappingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mappingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 280),
            mappingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mappingController.view.widthAnchor.constraint(equalToConstant: 300),
            mappingController.view.heightAnchor.constraint(equalToConstant: 300)
        ])
        mappingController.didMove(toParent: self)
    }
    
    func setupQuickBooking() {
        var skip: Bool = false
        var foundAvailableRoom = false
        for location in locations {
            
            if !UserDefaults.standard.isInWharton() {
                skip = true
            }
            
            if (location.kind == .wharton) && skip {
                continue
            }
            
            GSRNetworkManager.instance.getAvailability(lid: location.lid, gid: location.gid, startDate: nil) { [self] result in
                switch result {
                case .success(let rooms):
                    if !rooms.isEmpty {
                        self.startingLocation = location
                        self.allRooms = rooms
                        self.getSoonestTimeSlot()
                        foundAvailableRoom = true
                    }
                case .failure:
                    present(toast: .apiError)
                }
            }
            
            if !foundAvailableRoom && location == self.locations.last {
                present(toast: .apiError)
            }
        }
    }
    
    func setupSubmitButton() {
        view.addSubview(submitButton)
        submitButton.addTarget(self, action: #selector(quickBook(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 600),
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
                self?.unpreferButton.setTitle(option.name, for: .normal)
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
