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
        return MKCoordinateRegionMakeWithDistance(getDefault(), scale.rawValue, scale.rawValue)
    }
    
    func getCoordinates(for venue: DiningVenueName) -> CLLocationCoordinate2D {
        switch venue {
        case .commons:          return CLLocationCoordinate2D(latitude: 39.952456, longitude: -75.199393)
        case .pret:             return CLLocationCoordinate2D(latitude: 39.952501, longitude: -75.198419)
        case .falk:             return CLLocationCoordinate2D(latitude: 39.953187, longitude: -75.200089)
        case .english:          return CLLocationCoordinate2D(latitude: 39.953995, longitude: -75.193837)
        case .beefsteak:        return CLLocationCoordinate2D(latitude: 39.950945, longitude: -75.193945)
        case .frontera:         return CLLocationCoordinate2D(latitude: 39.952244, longitude: -75.195222)
        case .gourmetGrocer:    return CLLocationCoordinate2D(latitude: 39.952456, longitude: -75.199393)
        case .hill:             return CLLocationCoordinate2D(latitude: 39.953016, longitude: -75.190738)
        case .houston:          return CLLocationCoordinate2D(latitude: 39.951001, longitude: -75.194038)
        case .joes:             return CLLocationCoordinate2D(latitude: 39.951542, longitude: -75.196524)
        case .marks:            return CLLocationCoordinate2D(latitude: 39.952736, longitude: -75.194344)
        case .mbaCafe:          return CLLocationCoordinate2D(latitude: 39.953003, longitude: -75.198197)
        case .mcclelland:       return CLLocationCoordinate2D(latitude: 39.950422, longitude: -75.196937)
        case .nch:              return CLLocationCoordinate2D(latitude: 39.953969, longitude: -75.191060)
        case .starbucks:        return CLLocationCoordinate2D(latitude: 39.952343, longitude: -75.199541)
        case .unknown:          return getDefault()
        }
    }
    
    func getRegion(for venue: DiningVenueName, at scale: PennCoordinateScale) -> MKCoordinateRegion {
        return MKCoordinateRegionMakeWithDistance(getCoordinates(for: venue), scale.rawValue, scale.rawValue)
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
        return MKCoordinateRegionMakeWithDistance(getCoordinates(for: facility), scale.rawValue, scale.rawValue)
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
    
    func getAnnotation(for venue: DiningVenueName) -> MKAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = getCoordinates(for: venue)
        annotation.title = DiningVenueName.getVenueName(for: venue)
        annotation.subtitle = "Penn Dining"
        return annotation
    }
}

