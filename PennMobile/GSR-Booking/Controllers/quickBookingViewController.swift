//
//  quickBookingViewController.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 10/5/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class QuickBookingViewController: UIViewController, ShowsAlert {
    
    var locations: [GSRLocation] = GSRLocationModel.shared.getLocations()
    fileprivate var selectedOption: String?
    fileprivate var currentLocation: String?
    fileprivate var prefList: [GSRLocation] = []
    fileprivate var locRankedList: [GSRLocation] = []
    fileprivate var prefLocation: GSRLocation!
    
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
    
    public let GSRCoords = [
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.prefList = locations
        setupUnpreferButton()
        setupBook()
        setupDescriptionLabel()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        bookButton.addTarget(self, action: #selector(findGSRButtonPressed), for: .touchUpInside)
        prefList = orderLocations()
    }
    
    fileprivate let unpreferButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Preferred Location", for: .normal)
        button.setTitleColor(UIColor(named: "labelPrimary"), for: .normal)
        button.backgroundColor = UIColor(red: 2.0 / 255, green: 192.0 / 255, blue: 92.0 / 255, alpha: 1.0)
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate let bookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        button.setTitleColor(UIColor(named: "labelPrimary"), for: .normal)
        button.backgroundColor = UIColor(red: 2.0 / 255, green: 192.0 / 255, blue: 92.0 / 255, alpha: 1.0)
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate let roomLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .uiBackgroundSecondary
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .labelPrimary
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let descriptionLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .uiGroupedBackgroundSecondary
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .labelPrimary
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    fileprivate func setupDescriptionLabel() {
        descriptionLabel.text = """
            
                Quickly book the soonest available room 
                in any location on campus.  
            
                Preferred location will be booked over  
                other locations with the same soonest   
                available time.    
            
            """
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 180),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalToConstant: 350)
        ])
    }
    
    @objc fileprivate func findGSRButtonPressed() {
        prefList = makePreference()
        self.setupQuickBooking {
            let SheetVC = QuickBookSheetViewController(soonestLocation: self.soonestLocation)

            SheetVC.modalPresentationStyle = .pageSheet
            if let sheet = SheetVC.sheetPresentationController {
                sheet.detents = [.large(), .large()]
                sheet.prefersGrabberVisible = true
            }
                    
            self.present(SheetVC, animated: true, completion: nil)
            SheetVC.setupDisplay(startSlot: self.soonestStartTimeString, endSlot: self.soonestEndTimeString, room: self.soonestRoom, location: self.soonestLocation)
            SheetVC.setupMapping()
        }
    }
    
    fileprivate func setupQuickBooking(completion: @escaping () -> Void) {
        DispatchQueue.global().async { [self] in
            var skip: Bool = false
            var foundAvailableRoom = false
            for location in prefList {
                
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
            DispatchQueue.main.async {
                if self.soonestRoom != nil {
                    completion()
                }
            }
        }
    }

    
    fileprivate func setupUnpreferButton() {
        view.addSubview(unpreferButton)
        unpreferButton.addTarget(self, action: #selector(showDropdown), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            unpreferButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            unpreferButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unpreferButton.widthAnchor.constraint(equalToConstant: 300),
            unpreferButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    fileprivate func makePreference() -> [GSRLocation] {
        if prefLocation == nil {
            return prefList
        } else {
            self.prefList.insert(self.prefLocation, at: 0)
            return prefList
        }
    }
    
    @objc func showDropdown() {
        let alertController = UIAlertController(title: "Choose an option", message: nil, preferredStyle: .actionSheet)
        
        for option in locations {
            alertController.addAction(UIAlertAction(title: option.name, style: .default, handler: { [weak self] _ in
                self?.selectedOption = option.name
                self!.prefLocation = (self?.locations.first(where: { $0.name == self?.selectedOption })!)!
                self?.unpreferButton.setTitle(option.name, for: .normal)
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func setupBook() {
        view.addSubview(bookButton)
        
        NSLayoutConstraint.activate([
            bookButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            bookButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bookButton.widthAnchor.constraint(equalToConstant: 200),
            bookButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    public func getSoonestTimeSlot() {
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
    
extension QuickBookingViewController: CLLocationManagerDelegate {
    
    fileprivate func orderLocations() -> [GSRLocation] {
        locRankedList = locations
        locRankedList.sort { (loc1, loc2) in
            guard let loc1Coords = GSRCoords.first(where: { $0.title == loc1.name }),
                  let loc2Coords = GSRCoords.first(where: { $0.title == loc2.name }) else {
                return false
            }
            let loc1 = CLLocation(latitude: loc1Coords.latitude, longitude: loc1Coords.longitude)
            let loc2 = CLLocation(latitude: loc2Coords.latitude, longitude: loc2Coords.longitude)
            let distance1 = locationManager.location!.distance(from: loc1)
            let distance2 = locationManager.location!.distance(from: loc2)

            return distance1 < distance2
        }
        return locRankedList
    }

    fileprivate func setupLocationManager() {
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
    
    public func getSoonestLocation() -> String {
        return soonestLocation.name;
    }
    
    public func getRoom() -> UILabel {
        return roomLabel;
    }
}

extension QuickBookingViewController: GSRBookable {
    @objc public func quickBook(_ sender: Any) {
        if !Account.isLoggedIn {
            self.showAlert(withMsg: "You are not logged in!", title: "Error", completion: {self.navigationController?.popViewController(animated: true)})
        } else {
            submitBooking(for: GSRBooking(gid: soonestLocation.gid, startTime: soonesTimeSlot.startTime, endTime: soonesTimeSlot.endTime, id: soonestRoom.id, roomName: soonestRoom.roomName))
        }
    }
}
