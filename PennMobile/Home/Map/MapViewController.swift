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
    
    fileprivate var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.title = "Penn Map"
    }
}

extension MapViewController {
    
    fileprivate func setupMap() {
        mapView = getMapView()
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}

extension MapViewController {
    
    fileprivate func getMapView() -> MKMapView {
        let mv = MKMapView(frame: view.frame)
        mv.setRegion(PennCoordinate.shared.getDefaultRegion(at: .far), animated: false)
        mv.translatesAutoresizingMaskIntoConstraints = false
        return mv
    }
}
