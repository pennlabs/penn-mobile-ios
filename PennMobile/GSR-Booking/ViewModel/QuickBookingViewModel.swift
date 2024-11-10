//
//  QuickBookingViewModel.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 11/10/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

// ViewModels/QuickBookingViewModel.swift

import CoreLocation

public protocol QuickBookingViewModelDelegate: AnyObject {
    func updateRoomLabel()
    func updateMapping()
    func showAlert(message: String)
}

public class QuickBookingViewModel {
    
    public weak var delegate: QuickBookingViewModelDelegate?
    
    private var prefList: [GSRLocation] = []
    private var soonestRoom: GSRRoom?
    private var soonestLocation: GSRLocation?
    private var soonestStartTimeString: String?
    private var soonestEndTimeString: String?
    
    private var locRankedList: [GSRLocation?]
    
    public var destinationCoordinate: CLLocationCoordinate2D?
    
    public init() {}
    
    public func orderLocations(completion: @escaping () -> Void) {
        locRankedList = GSRLocationModel.shared.getLocations()
locRankedList.sorted { swap(d1: $0, d2: $1) }
        completion()
    }
    
    public func findGSRButtonPressed() {
        setupQuickBooking {
            self.delegate?.updateRoomLabel()
            self.delegate?.updateMapping()
        }
    }
    
    public func setupQuickBooking(completion: @escaping () -> Void) {
        // Network call and logic to find available GSR
        GSRNetworkManager.instance.getAvailability { rooms in
            if let room = rooms.first {
                self.soonestRoom = room
                self.delegate?.updateRoomLabel()
                completion()
            }
        }
    }
    
    public func showDropdown() {
        // Handle showing the dropdown for selecting preferred location
    }
    
    public func submitBooking() {
        // Submit the booking logic
    }
    
    private func swap(d1: GSRLocation, d2: GSRLocation) -> Bool {
        return distance(loc: d1) > distance(loc: d2)
    }

    private func distance(loc: GSRLocation) -> Int {
        guard let userLocation = locationManager.location else { return Int.max }
        guard let coords = GSRCoords.first(where: { $0.title == loc.name }) else { return Int.max }
        
        let lat = coords.latitude
        let long = coords.longitude
        let userLat = userLocation.coordinate.latitude
        let userLong = userLocation.coordinate.longitude
        
        let stepLat = (userLat - lat) * (userLat - lat)
        let stepLong = (userLong - long) * (userLong - long)
        return Int(round(sqrt(stepLat + stepLong)))
    }
}
