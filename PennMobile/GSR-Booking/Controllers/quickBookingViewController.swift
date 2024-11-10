//
//  quickBookingViewController.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 10/5/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//
// Controllers/QuickBookingViewController.swift

// Controllers/QuickBookingViewController.swift
import UIKit
import CoreLocation
import MapKit

class QuickBookingViewController: UIViewController, CLLocationManagerDelegate {
    
    private let viewModel = QuickBookingViewModel()
    private let locationManager = CLLocationManager()
    
    // UI Elements
    private let quickBookingView = QuickBookingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        QuickBookingView.instance.setupUI()
        viewModel.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        quickBookingView.bookButton.addTarget(self, action: #selector(findGSRButtonPressed), for: .touchUpInside)
        quickBookingView.submitButton.addTarget(self, action: #selector(submitBooking), for: .touchUpInside)
        quickBookingView.unpreferButton.addTarget(self, action: #selector(showDropdown), for: .touchUpInside)
    }
    
    @objc private func findGSRButtonPressed() {
        viewModel.findGSRButtonPressed()
    }
    
    @objc private func submitBooking() {
        if !Account.isLoggedIn {
            showAlert(withMsg: "You are not logged in!", title: "Error", completion: { self.navigationController?.popViewController(animated: true) })
        } else {
            viewModel.submitBooking()
        }
    }
    
    @objc private func showDropdown() {
        viewModel.showDropdown()
    }
}

extension QuickBookingViewController: QuickBookingViewModelDelegate, ShowsAlert {
    func updateRoomLabel() {
        quickBookingView.updateRoomLabel(
            startTime: viewModel.soonestStartTimeString!,
            endTime: viewModel.soonestEndTimeString,
            roomName: viewModel.soonestRoom?.roomName,
            locationName: viewModel.soonestLocation?.name
        )
    }

    func updateMapping() {
        quickBookingView.updateMappingView(coordinate: viewModel.destinationCoordinate)
    }
    
    func showAlert(message: String) {
        presentAlert(message)
    }
}
