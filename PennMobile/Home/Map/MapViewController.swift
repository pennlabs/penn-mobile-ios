//
//  MapViewController.swift
//  PennMobile
//
//  Created by Dominic Holmes on 8/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    fileprivate var mapView: MKMapView?
    
    var venue: DiningVenueName? {
        didSet {
            guard let venue = venue else { return }
            self.region = PennCoordinate.shared.getRegion(for: venue, at: .close)
            self.annotation = PennCoordinate.shared.getAnnotation(for: venue)
        }
    }
    
    var facility: FitnessFacilityName? {
        didSet {
            guard let facility = facility else { return }
            self.region = PennCoordinate.shared.getRegion(for: facility, at: .close)
            self.annotation = PennCoordinate.shared.getAnnotation(for: facility)
        }
    }
    
    var region: MKCoordinateRegion = PennCoordinate.shared.getDefaultRegion(at: .far) {
        didSet {
            if let _ = mapView {
                mapView?.setRegion(region, animated: false)
            }
        }
    }
    var annotation: MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.title = "Penn Map" // THIS DOESN'T WORK
    }
}

extension MapViewController {
    
    fileprivate func setupMap() {
        mapView = getMapView()
        view.addSubview(mapView!)
        NSLayoutConstraint.activate([
            mapView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView!.topAnchor.constraint(equalTo: view.topAnchor),
            mapView!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}

extension MapViewController {
    
    fileprivate func getMapView() -> MKMapView {
        let mv = MKMapView(frame: view.frame)
        mv.setRegion(region, animated: false)
        if annotation != nil { mv.addAnnotation(annotation!) }
        mv.translatesAutoresizingMaskIntoConstraints = false
        return mv
    }
}
