//
//  PennCoordinates.swift
//  PennMobile
//
//  Created by Dominic Holmes on 8/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import MapKit
import PennMobileShared

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

    // Keeping for future reference!
//    func getCoordinates(for facility: FitnessFacilityName) -> CLLocationCoordinate2D {
//        switch facility {
//        case .pottruck:     return CLLocationCoordinate2D(latitude: 39.953562, longitude: -75.197002)
//        case .fox:          return CLLocationCoordinate2D(latitude: 39.950343, longitude: -75.189154)
//        case .climbing:     return CLLocationCoordinate2D(latitude: 39.954034, longitude: -75.196960)
//        case .membership:   return CLLocationCoordinate2D(latitude: 39.954057, longitude: -75.197188)
//        case .ringe:        return CLLocationCoordinate2D(latitude: 39.950450, longitude: -75.188642)
//        case .rockwell:     return CLLocationCoordinate2D(latitude: 39.953859, longitude: -75.196868)
//        case .sheerr:       return CLLocationCoordinate2D(latitude: 39.953859, longitude: -75.196868)
//        case .unknown:      return getDefault()
//        }
//    }
//    
//    func getAnnotation(for facility: FitnessFacilityName) -> MKAnnotation {
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = getCoordinates(for: facility)
//        annotation.title = facility.getFacilityName()
//        annotation.subtitle = "Penn Recreation"
//        return annotation
//    }
//
//    func getRegion(for facility: FitnessFacilityName, at scale: PennCoordinateScale) -> MKCoordinateRegion {
//        return MKCoordinateRegion.init(center: getCoordinates(for: facility), latitudinalMeters: scale.rawValue, longitudinalMeters: scale.rawValue)
//    }

    func getCoordinates(for dining: DiningVenue) -> CLLocationCoordinate2D {
        switch dining.id {
        case 593:
            // 1920 Commons
            return CLLocationCoordinate2D(latitude: 39.952275, longitude: -75.199560)
        case 636:
            // Hill House
            return CLLocationCoordinate2D(latitude: 39.953040, longitude: -75.190589)
        case 637:
            // English House
            return CLLocationCoordinate2D(latitude: 39.954242, longitude: -75.194351)
        case 638:
            // Falk Kosher Dining
            return CLLocationCoordinate2D(latitude: 39.953117, longitude: -75.200075)
        case 639:
            // Houston Market
            return CLLocationCoordinate2D(latitude: 39.950920, longitude: -75.193892)
        case 641:
            // "Accenture Caf\u00e9"
            return CLLocationCoordinate2D(latitude: 39.951827, longitude: -75.191315)
        case 642:
            // "Joe's Caf\u00e9"
            return CLLocationCoordinate2D(latitude: 39.951818, longitude: -75.196089)
        case 1442:
            // "Lauder College House"
            return CLLocationCoordinate2D(latitude: 39.953907, longitude: -75.191733)
        case 747:
            // "McClelland Express"
            return CLLocationCoordinate2D(latitude: 39.950378, longitude: -75.197151)
        case 1057:
            // "1920 Gourmet Grocer"
            return CLLocationCoordinate2D(latitude: 39.952115, longitude: -75.199492)
        case 1163:
            // "1920 Starbucks"
            return CLLocationCoordinate2D(latitude: 39.952361, longitude: -75.199466)
        case 1731:
            // "LCH Retail"
            return CLLocationCoordinate2D(latitude: 39.953907, longitude: -75.191733)
        case 1732:
            // Pret a Manger MBA
            return CLLocationCoordinate2D(latitude: 39.952591, longitude: -75.198326)
        default:
            // case 1733:
            // "Pret a Manger Locust Walk",
            return CLLocationCoordinate2D(latitude: 39.952591, longitude: -75.198326)
        }
    }

    func getRegion(for dining: DiningVenue, at scale: PennCoordinateScale) -> MKCoordinateRegion {
        return MKCoordinateRegion.init(center: getCoordinates(for: dining), latitudinalMeters: scale.rawValue, longitudinalMeters: scale.rawValue)
    }
}
