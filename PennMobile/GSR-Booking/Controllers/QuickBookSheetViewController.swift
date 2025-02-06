//
//  QuickBookSheetView.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 2/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class QuickBookSheetViewController : UIViewController {
    let mapVC = MapViewController()
    let mappingController = GSRMappingController()
    let quickBooking = QuickBookingViewController()
    var soonestLocation: GSRLocation
    
    init(soonestLocation: GSRLocation) {
        self.soonestLocation = soonestLocation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = .uiBackground
        setupSubmitButton()
    }
    
    fileprivate let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
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
    
    internal func setupMapping() {
        var lat: CLLocationDegrees!
        var long: CLLocationDegrees!
        if let coords = quickBooking.GSRCoords.first(where: { $0.title == soonestLocation.name}) {
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
    
    fileprivate func setupSubmitButton() {
        view.addSubview(submitButton)
        submitButton.addTarget(self, action: #selector(QuickBookingViewController.quickBook(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 600),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 300),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    internal func setupDisplay(startSlot: String, endSlot: String, room: GSRRoom, location: GSRLocation) {
        quickBooking.getRoom().text = """
            Soonest available GSR:
            Time Slot: \(startSlot) to \(endSlot)
            Room: \(room.roomName)
            Location: \(location.name)
            """
        view.addSubview(quickBooking.getRoom())
        
        NSLayoutConstraint.activate([
            quickBooking.getRoom().topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 180),
            quickBooking.getRoom().centerXAnchor.constraint(equalTo: view.centerXAnchor),
            quickBooking.getRoom().widthAnchor.constraint(equalToConstant: 300)
        ])
    }
}


