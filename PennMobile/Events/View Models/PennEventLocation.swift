//
//  PennEventLocation.swift
//  PennMobile
//
//  Created by Jacky on 3/27/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation

struct PennEventLocation: Identifiable {
    
    let id = UUID()
    
    let name: String
    
    let coordinate: CLLocationCoordinate2D
    
    
    // locations
    static let pennEventLocations: [PennEventLocation] = [
        PennEventLocation(name: "Moore", coordinate: CLLocationCoordinate2D(latitude: 39.95235195358212, longitude: -75.1905628341613)),
        PennEventLocation(name: "Levine", coordinate: CLLocationCoordinate2D(latitude: 39.9523636592379, longitude: -75.19108716260482)),
        PennEventLocation(name: "Skirchanich", coordinate: CLLocationCoordinate2D(latitude: 39.95203211923665, longitude: -75.19053972646232)),
        PennEventLocation(name: "Towne", coordinate: CLLocationCoordinate2D(latitude: 39.95176422072041, longitude: -75.19094966518134)),
        PennEventLocation(name: "Fisher Bennett Hall", coordinate: CLLocationCoordinate2D(latitude: 39.95250634854153, longitude: -75.1918248868187)),
        PennEventLocation(name: "LRSM", coordinate: CLLocationCoordinate2D(latitude: 39.9529344527566, longitude: -75.18970192557583)),
        PennEventLocation(name: "Singh Center", coordinate: CLLocationCoordinate2D(latitude: 39.95290313241999, longitude: -75.18890554376047)),
        PennEventLocation(name: "DRL", coordinate: CLLocationCoordinate2D(latitude: 39.95193139049961, longitude: -75.18985605961376)),
        PennEventLocation(name: "Vagelos Lab", coordinate: CLLocationCoordinate2D(latitude: 39.951324472746634, longitude: -75.19212315793388)),
        PennEventLocation(name: "Hayden Hall", coordinate: CLLocationCoordinate2D(latitude: 39.95130364421386, longitude: -75.19124840738166)),
        PennEventLocation(name: "Chem Lab", coordinate: CLLocationCoordinate2D(latitude: 39.95080231715675, longitude: -75.1924193409095)),
        PennEventLocation(name: "Morgan Center", coordinate: CLLocationCoordinate2D(latitude: 39.95192608237323, longitude: -75.1920054094594)),
        PennEventLocation(name: "Meyerson", coordinate: CLLocationCoordinate2D(latitude: 39.95225671565781, longitude: -75.19267579780164)),
        PennEventLocation(name: "Fisher Fine Arts", coordinate: CLLocationCoordinate2D(latitude: 39.9517663757864, longitude: -75.19265233980819)),
        PennEventLocation(name: "Irvine", coordinate: CLLocationCoordinate2D(latitude: 39.950940871334346, longitude: -75.19298471927173)),
        PennEventLocation(name: "Houston", coordinate: CLLocationCoordinate2D(latitude: 39.95095210231154, longitude: -75.19383998394906)),
        PennEventLocation(name: "College Hall", coordinate: CLLocationCoordinate2D(latitude: 39.95153037060008, longitude: -75.19379532295793)),
        PennEventLocation(name: "Williams", coordinate: CLLocationCoordinate2D(latitude: 39.95094576807124, longitude: -75.1948119503)),
        PennEventLocation(name: "Claudia Cohen", coordinate: CLLocationCoordinate2D(latitude: 39.95139530994063, longitude: -75.19475231325019)),
        PennEventLocation(name: "ARB", coordinate: CLLocationCoordinate2D(latitude: 39.95129828577706, longitude: -75.19683445915696)),
        PennEventLocation(name: "Steinberg-Dietrich", coordinate: CLLocationCoordinate2D(latitude: 39.95189543035373, longitude: -75.19638290887475)),
        PennEventLocation(name: "Jaffe History of Art", coordinate: CLLocationCoordinate2D(latitude: 39.95273533555461, longitude: -75.1929464299296)),
        PennEventLocation(name: "Van Pelt Library", coordinate: CLLocationCoordinate2D(latitude: 39.952635958734824, longitude: -75.19344631852594)),
        PennEventLocation(name: "Annenberg", coordinate: CLLocationCoordinate2D(latitude: 39.95295865404018, longitude: -75.19586669018221)),
        PennEventLocation(name: "Harrison", coordinate: CLLocationCoordinate2D(latitude: 39.95191883398914, longitude: -75.20111961064812)),
        PennEventLocation(name: "Gutmann", coordinate: CLLocationCoordinate2D(latitude: 39.95378369040921, longitude: -75.20209860371801)),
        PennEventLocation(name: "Radian", coordinate: CLLocationCoordinate2D(latitude: 39.95426285980732, longitude: -75.20118913499053)),
        PennEventLocation(name: "Du Bois", coordinate: CLLocationCoordinate2D(latitude: 39.953729053974726, longitude: -75.20100366821694)),
        PennEventLocation(name: "Rodin", coordinate: CLLocationCoordinate2D(latitude: 39.95317963582513, longitude: -75.2013287633819)),
        PennEventLocation(name: "Gregory", coordinate: CLLocationCoordinate2D(latitude: 39.95284062848591, longitude: -75.2024690313161)),
        PennEventLocation(name: "Harnwell", coordinate: CLLocationCoordinate2D(latitude: 39.95239945381507, longitude: -75.20011766975578)),
        PennEventLocation(name: "Stouffer", coordinate: CLLocationCoordinate2D(latitude: 39.951618752554566, longitude: -75.20025454470158)),
        PennEventLocation(name: "Lauder", coordinate: CLLocationCoordinate2D(latitude: 39.95371471491931, longitude: -75.19129026404389)),
        PennEventLocation(name: "Hill", coordinate: CLLocationCoordinate2D(latitude: 39.95302883232131, longitude: -75.19067853565349)),
        PennEventLocation(name: "KCEH", coordinate: CLLocationCoordinate2D(latitude: 39.954270105221795, longitude: -75.19388456903467)),
        PennEventLocation(name: "Fisher", coordinate: CLLocationCoordinate2D(latitude: 39.950494278320406, longitude: -75.1978243723441)),
        PennEventLocation(name: "Ware", coordinate: CLLocationCoordinate2D(latitude: 39.95038566116001, longitude: -75.1965884401402)),
        PennEventLocation(name: "Riepe", coordinate: CLLocationCoordinate2D(latitude: 39.95024529610172, longitude: -75.19591924939768))
    ]
    
    static func coordinateForEvent(location: String, eventName: String, eventType: String) -> CLLocationCoordinate2D? {
        // process string and find coordinate method
        func findCoordinate(from string: String) -> CLLocationCoordinate2D? {
            let parts = string.lowercased().split(separator: " ").map(String.init)
            for part in parts {
                if let matchingLocation = pennEventLocations.first(where: { $0.name.lowercased().contains(part) }) {
                    
                    print("Matching \(part): '\(part)' with location '\(matchingLocation.name)'")
                    
                    return matchingLocation.coordinate
                }
            }
            print("No match found in \(string) for string: \(string)")
            return nil
        }

        // check first the event type, then location, then the event title
        if let coordinate = findCoordinate(from: eventType) {
            return coordinate
        }
        if location.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() != "No Location" {
            if let coordinate = findCoordinate(from: location) {
                return coordinate
            }
        }
        if let coordinate = findCoordinate(from: eventName) {
            return coordinate
        }

        // default location, philadelphia
        return CLLocationCoordinate2D(latitude: 39.9522, longitude: -75.1932)
    }
}


