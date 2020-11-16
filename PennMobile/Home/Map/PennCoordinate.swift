//
//  PennCoordinates.swift
//  PennMobile
//
//  Created by Dominic Holmes on 8/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import MapKit

enum PennCoordinateScale: Double {
    case close = 150.0
    case mid = 300.0
    case far   = 1000.0
}

// MARK: - Coordinates and Regions
class PennCoordinate {
    
    static let shared = PennCoordinate()
    internal let collegeHall: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 39.9522, longitude: -75.1932)
    
    func getDefault() -> CLLocationCoordinate2D {
        return collegeHall
    }
    
    func getDefaultRegion(at scale: PennCoordinateScale) -> MKCoordinateRegion {
        return MKCoordinateRegion.init(center: getDefault(), latitudinalMeters: scale.rawValue, longitudinalMeters: scale.rawValue)
    }
    
    func getCoordinates(for facility: FitnessFacilityName) -> CLLocationCoordinate2D {
        switch facility {
        case .pottruck:     return CLLocationCoordinate2D(latitude: 39.953562, longitude: -75.197002)
        case .fox:          return CLLocationCoordinate2D(latitude: 39.950343, longitude: -75.189154)
        case .climbing:     return CLLocationCoordinate2D(latitude: 39.954034, longitude: -75.196960)
        case .membership:   return CLLocationCoordinate2D(latitude: 39.954057, longitude: -75.197188)
        case .ringe:        return CLLocationCoordinate2D(latitude: 39.950450, longitude: -75.188642)
        case .rockwell:     return CLLocationCoordinate2D(latitude: 39.953859, longitude: -75.196868)
        case .sheerr:       return CLLocationCoordinate2D(latitude: 39.953859, longitude: -75.196868)
        case .unknown:      return getDefault()
        }
    }
    
    func getRegion(for facility: FitnessFacilityName, at scale: PennCoordinateScale) -> MKCoordinateRegion {
        return MKCoordinateRegion.init(center: getCoordinates(for: facility), latitudinalMeters: scale.rawValue, longitudinalMeters: scale.rawValue)
    }
    
    // TODO: Implement a switch statement that matches GSR venue IDs with GPS coords
    func getCoordinates(for gsr: GSRVenue) -> CLLocationCoordinate2D {
        return getDefault()
    }
}

// MARK: - Placemarks
extension PennCoordinate {
    
    func getAnnotation(for facility: FitnessFacilityName) -> MKAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = getCoordinates(for: facility)
        annotation.title = facility.getFacilityName()
        annotation.subtitle = "Penn Recreation"
        return annotation
    }
}

