//
//  MapViewController.swift
//  PennMobile
//
//  Created by Dominic Holmes on 8/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class MapViewController: UIViewController {

    fileprivate var mapView: MKMapView?

    var searchTerm: String?

    var building: BuildingMapDisplayable? {
        didSet {
            guard let building = building else { return }
            self.region = building.getRegion()
            self.annotation = building.getAnnotation()
        }
    }

    var region: MKCoordinateRegion = PennCoordinate.shared.getDefaultRegion(at: .far) {
        didSet {
            mapView?.setRegion(region, animated: false)
        }
    }
    var annotation: MKAnnotation?

    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Penn Map"

        guard let searchTerm = searchTerm else { return }
        self.navigationController?.navigationItem.backBarButtonItem?.title = "Back"

        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .denied:
                // Do nothing, handle in didChangeAuthorization delegate function
                self.locationManager.requestWhenInUseAuthorization()
            default:
                showCoordinates(searchTerm: searchTerm)
            }
        } else {
            showCoordinates(searchTerm: searchTerm)
        }
    }

    fileprivate func showCoordinates(searchTerm: String) {
        self.region = MKCoordinateRegion.init(center: PennCoordinate.shared.getDefault(), latitudinalMeters: PennCoordinateScale.mid.rawValue, longitudinalMeters: PennCoordinateScale.mid.rawValue)
        self.getCoordinates(for: searchTerm) { (coordinates, title) in
            DispatchQueue.main.async {
                if let coordinates = coordinates {
                    if let title = title {
                        let thisAnnotation = MKPointAnnotation()
                        thisAnnotation.coordinate = coordinates
                        thisAnnotation.title = title
                        thisAnnotation.subtitle = title
                        self.annotation = thisAnnotation
                        self.mapView?.addAnnotation(thisAnnotation)
                    }

                    if let annotation = self.annotation, self.hasLocationPermission() {
                        let userLoc = self.mapView!.userLocation
                        let newDistance = CLLocation(latitude: userLoc.coordinate.latitude, longitude: userLoc.coordinate.longitude).distance(from: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
                        let centerCoordinate = CLLocationCoordinate2DMake((userLoc.coordinate.latitude + annotation.coordinate.latitude) / 2.0, (userLoc.coordinate.longitude + annotation.coordinate.longitude) / 2.0)
                        let largeRegion = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 2 * newDistance, longitudinalMeters: 2 * newDistance)
                        self.region = self.mapView!.regionThatFits(largeRegion)
                    } else {
                        self.region = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: PennCoordinateScale.mid.rawValue, longitudinalMeters: PennCoordinateScale.mid.rawValue)
                    }
                } else {
                    self.region = MKCoordinateRegion.init(center: PennCoordinate.shared.getDefault(), latitudinalMeters: PennCoordinateScale.mid.rawValue, longitudinalMeters: PennCoordinateScale.mid.rawValue)
                }
            }
        }
    }
}

extension MapViewController {

    fileprivate func setupMap() {
        mapView = getMapView()
        mapView?.showsUserLocation = true
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

extension MapViewController {
    func getCoordinates(for searchTerm: String, _ callback: @escaping (_ coordinates: CLLocationCoordinate2D?, _ title: String?) -> Void) {
        let url = URL(string: "https://mobile.apps.upenn.edu/mobile/jsp/fast.do?webService=googleMapsSearch&searchTerm=\(searchTerm)")!
        let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data, let json = try? JSON(data: data), let locationJSON = json.arrayValue.first {
                if let latitudeStr = locationJSON["latitude"].string, let longitudeStr = locationJSON["longitude"].string, let title = locationJSON["title"].string {
                    if let latitude = Double(latitudeStr), let longitude = Double(longitudeStr) {
                        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        callback(coordinates, title)
                        return
                    }
                }
            }
            callback(nil, nil)
        }
        task.resume()
    }
}

extension MapViewController: LocationPermissionRequestable {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if let searchTerm = searchTerm {
            self.showCoordinates(searchTerm: searchTerm)
        }
    }
}
