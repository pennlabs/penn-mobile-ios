//
//  QuickBookAlertView.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 2/16/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class QuickBookAlertViewController: UIViewController, ShowsAlert {
    let mappingController = GSRMappingController()
    fileprivate var soonestTimeSlot: GSRTimeSlot!
    fileprivate var soonestRoom: GSRRoom!
    fileprivate var soonestLocation: GSRLocation!
    
    
    override func viewDidLoad() {
            super.viewDidLoad()
            setupSubmitAlert()
        }
    
    init(soonestLocation: GSRLocation, soonestTimeSlot: GSRTimeSlot, soonestRoom: GSRRoom) {
            self.soonestLocation = soonestLocation
            self.soonestTimeSlot = soonestTimeSlot
            self.soonestRoom = soonestRoom
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init not been implemented")
        }
    
    internal func setupSubmitAlert(){
        let alert = UIAlertController(title: "Quick Book GSR", message: """
            Soonest available GSR:
            Time Slot: \(soonestTimeSlot.startTime) to \(soonestTimeSlot.endTime)
            Room: \(soonestRoom.roomName)
            Location: \(soonestLocation.name)

            Quickly book the soonest available room in any location on campus.
            """, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
                alert.addAction(cancelAction)
        
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { _ in
            self.quickBook()
        }
        
        alert.addAction(acceptAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    internal func setupMapping() {
        let quicky = QuickBookingViewController()
        var lat: CLLocationDegrees!
        var long: CLLocationDegrees!
        if let coords = quicky.GSRCoords.first(where: { $0.title == soonestLocation.name}) {
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
    
}

extension QuickBookAlertViewController: GSRBookable {
    @objc internal func quickBook() {
        if !Account.isLoggedIn {
            self.showAlert(withMsg: "You are not logged in!", title: "Error", completion: {self.navigationController?.popViewController(animated: true)})
        } else {
            submitBooking(for: GSRBooking(gid: soonestLocation.gid, startTime: soonestTimeSlot.startTime, endTime: soonestTimeSlot.endTime, id: soonestRoom.id, roomName: soonestRoom.roomName))
        }
    }
}
