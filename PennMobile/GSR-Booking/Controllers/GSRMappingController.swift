//
//  GSRMappingController.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 10/25/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class GSRMappingController: UIViewController {
    var destinationCoordinate: CLLocationCoordinate2D? {
        didSet {
            if let coordinate = destinationCoordinate {
                updateMapAnnotations()
                drawRoute(to: coordinate)
            }
        }
    }

    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        return mapView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        updateMapAnnotations()
    }
    
    private func setupMapView() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func updateMapAnnotations() {
        guard let destinationCoordinate = destinationCoordinate else { return }

        mapView.removeAnnotations(mapView.annotations)
        
        if let userLocation = mapView.userLocation.location {
            let currentAnnotation = MKPointAnnotation()
            currentAnnotation.coordinate = userLocation.coordinate
            currentAnnotation.title = "Current Location"
            mapView.addAnnotation(currentAnnotation)
        }
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destinationCoordinate
        destinationAnnotation.title = "GSR Location"
        mapView.addAnnotation(destinationAnnotation)
        
        if let userLocation = mapView.userLocation.location {
            let midpoint = CLLocationCoordinate2D(
                        latitude: (userLocation.coordinate.latitude + destinationCoordinate.latitude) / 2,
                        longitude: (userLocation.coordinate.longitude + destinationCoordinate.longitude) / 2
            )
            let coordinates = [userLocation.coordinate, destinationCoordinate]
            let region = MKCoordinateRegion(center: midpoint, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
        }
    }
    
    private func drawRoute(to destinationCoordinate: CLLocationCoordinate2D) {
        guard let userLocation = mapView.userLocation.location else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = .automobile // Change as needed (automobile, walking, etc.)

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self, let response = response else {
                if let error = error {
                    print("Error calculating directions: \(error.localizedDescription)")
                }
                return
            }
            
            self.mapView.removeOverlays(self.mapView.overlays)
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            }
        }
    }
}

extension GSRMappingController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
