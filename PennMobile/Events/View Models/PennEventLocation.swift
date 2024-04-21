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
        
        // Dorms / Dining
        PennEventLocation(name: "Harrison", coordinate: CLLocationCoordinate2D(latitude: 39.9519532049742, longitude: -75.20112202851995)),
        PennEventLocation(name: "Gutmann", coordinate: CLLocationCoordinate2D(latitude: 39.95378369040921, longitude: -75.20209860371801)),
        PennEventLocation(name: "Radian", coordinate: CLLocationCoordinate2D(latitude: 39.95426285980732, longitude: -75.20118913499053)),
        PennEventLocation(name: "Du Bois", coordinate: CLLocationCoordinate2D(latitude: 39.953729053974726, longitude: -75.20100366821694)),
        PennEventLocation(name: "Rodin", coordinate: CLLocationCoordinate2D(latitude: 39.953172783587675, longitude: -75.20134377744817)),
        PennEventLocation(name: "Gregory", coordinate: CLLocationCoordinate2D(latitude: 39.95284062848591, longitude: -75.2024690313161)),
        PennEventLocation(name: "Harnwell", coordinate: CLLocationCoordinate2D(latitude: 39.95238375805794, longitude: -75.20015674568795)),
        PennEventLocation(name: "Stouffer", coordinate: CLLocationCoordinate2D(latitude: 39.951618752554566, longitude: -75.20025454470158)),
        PennEventLocation(name: "Lauder", coordinate: CLLocationCoordinate2D(latitude: 39.95371471491931, longitude: -75.19129026404389)),
        PennEventLocation(name: "Hill", coordinate: CLLocationCoordinate2D(latitude: 39.95302883232131, longitude: -75.19067853565349)),
        PennEventLocation(name: "KCECH", coordinate: CLLocationCoordinate2D(latitude: 39.954270105221795, longitude: -75.19388456903467)),
        PennEventLocation(name: "Fisher", coordinate: CLLocationCoordinate2D(latitude: 39.950494278320406, longitude: -75.1978243723441)),
        PennEventLocation(name: "Ware", coordinate: CLLocationCoordinate2D(latitude: 39.95038566116001, longitude: -75.1965884401402)),
        PennEventLocation(name: "Riepe", coordinate: CLLocationCoordinate2D(latitude: 39.95024529610172, longitude: -75.19591924939768)),
        PennEventLocation(name: "Hillel", coordinate: CLLocationCoordinate2D(latitude: 39.95313114632822, longitude: -75.20004461654126)),
        PennEventLocation(name: "Chestnut Hall", coordinate: CLLocationCoordinate2D(latitude: 39.95500054995168, longitude: -75.20030364098739)),
        
        // Engineering
        PennEventLocation(name: "Moore", coordinate: CLLocationCoordinate2D(latitude: 39.95235195358212, longitude: -75.1905628341613)),
        PennEventLocation(name: "Levine", coordinate: CLLocationCoordinate2D(latitude: 39.9523636592379, longitude: -75.19108716260482)),
        PennEventLocation(name: "Skirchanich", coordinate: CLLocationCoordinate2D(latitude: 39.95203211923665, longitude: -75.19053972646232)),
        PennEventLocation(name: "Towne", coordinate: CLLocationCoordinate2D(latitude: 39.95176216372684, longitude: -75.19096291431735)),
        PennEventLocation(name: "Fisher-Bennett Hall", coordinate: CLLocationCoordinate2D(latitude: 39.95250634854153, longitude: -75.1918248868187)),
        PennEventLocation(name: "LRSM", coordinate: CLLocationCoordinate2D(latitude: 39.9529344527566, longitude: -75.18970192557583)),
        PennEventLocation(name: "Singh Center", coordinate: CLLocationCoordinate2D(latitude: 39.95290313241999, longitude: -75.18890554376047)),
        PennEventLocation(name: "DRL", coordinate: CLLocationCoordinate2D(latitude: 39.95193139049961, longitude: -75.18985605961376)),
        PennEventLocation(name: "Vagelos Lab", coordinate: CLLocationCoordinate2D(latitude: 39.951324472746634, longitude: -75.19212315793388)),
        PennEventLocation(name: "Hayden Hall", coordinate: CLLocationCoordinate2D(latitude: 39.95130364421386, longitude: -75.19124840738166)),
        PennEventLocation(name: "Chem Lab", coordinate: CLLocationCoordinate2D(latitude: 39.95080231715675, longitude: -75.1924193409095)),
        PennEventLocation(name: "Quain Courtyard", coordinate: CLLocationCoordinate2D(latitude: 39.952186767661445, longitude: -75.19087984244156)),
        PennEventLocation(name: "Morgan Building", coordinate: CLLocationCoordinate2D(latitude: 39.95192608237323, longitude: -75.1920054094594)),
                
        // Wharton
        PennEventLocation(name: "Huntsman", coordinate: CLLocationCoordinate2D(latitude: 39.95307761065585, longitude: -75.19817525836665)),
        PennEventLocation(name: "ARB", coordinate: CLLocationCoordinate2D(latitude: 39.95129828577706, longitude: -75.19683445915696)),
        PennEventLocation(name: "Steinberg-Dietrich", coordinate: CLLocationCoordinate2D(latitude: 39.95189543035373, longitude: -75.19638290887475)),
        
        // College Green (Center of Campus)
        PennEventLocation(name: "Van Pelt Library", coordinate: CLLocationCoordinate2D(latitude: 39.952635958734824, longitude: -75.19344631852594)),
        PennEventLocation(name: "Meyerson", coordinate: CLLocationCoordinate2D(latitude: 39.95225671565781, longitude: -75.19267579780164)),
        PennEventLocation(name: "Fisher Fine Arts", coordinate: CLLocationCoordinate2D(latitude: 39.9517663757864, longitude: -75.19265233980819)),
        PennEventLocation(name: "Irvine", coordinate: CLLocationCoordinate2D(latitude: 39.950940871334346, longitude: -75.19298471927173)),
        PennEventLocation(name: "Houston", coordinate: CLLocationCoordinate2D(latitude: 39.95095210231154, longitude: -75.19383998394906)),
        PennEventLocation(name: "College Hall", coordinate: CLLocationCoordinate2D(latitude: 39.95153037060008, longitude: -75.19379532295793)),
        PennEventLocation(name: "Williams", coordinate: CLLocationCoordinate2D(latitude: 39.95094576807124, longitude: -75.1948119503)),
        PennEventLocation(name: "Claudia Cohen", coordinate: CLLocationCoordinate2D(latitude: 39.95139530994063, longitude: -75.19475231325019)),
        PennEventLocation(name: "Jaffe History of Art", coordinate: CLLocationCoordinate2D(latitude: 39.95273533555461, longitude: -75.1929464299296)),
        PennEventLocation(name: "Button", coordinate: CLLocationCoordinate2D(latitude: 39.95224256696289, longitude: -75.19370479455685)),
        PennEventLocation(name: "ARCH", coordinate: CLLocationCoordinate2D(latitude: 39.95226833804672, longitude: -75.19522519154951)),
        PennEventLocation(name: "Fagin", coordinate: CLLocationCoordinate2D(latitude: 39.94916855135187, longitude: -75.19601396188439)),
        PennEventLocation(name: "Biotech Commons", coordinate: CLLocationCoordinate2D(latitude: 39.949613882578554, longitude: -75.19568901147446)),
        PennEventLocation(name: "John Morgan", coordinate: CLLocationCoordinate2D(latitude: 39.94966434275017, longitude: -75.19674870191758)),
        PennEventLocation(name: "McNeil", coordinate: CLLocationCoordinate2D(latitude: 39.95199130686178, longitude: -75.19790657805316)),
        PennEventLocation(name: "Graduate School of Education", coordinate: CLLocationCoordinate2D(latitude: 39.9532241847759, longitude: -75.19719927300316)),
        PennEventLocation(name: "Annenberg Center", coordinate: CLLocationCoordinate2D(latitude: 39.9529727652777, longitude: -75.19646525419347)),
        PennEventLocation(name: "Annenberg School", coordinate: CLLocationCoordinate2D(latitude: 39.953001412780914, longitude: -75.19585568212437)),
        PennEventLocation(name: "Charles Addams Fine Arts", coordinate: CLLocationCoordinate2D(latitude: 39.9530180073702, longitude: -75.19518859805397)),
        
        // Misc Locations (West Campus)
        PennEventLocation(name: "Levin", coordinate: CLLocationCoordinate2D(latitude: 39.949548199883495, longitude: -75.19904304261793)),
        PennEventLocation(name: "Vance Hall", coordinate: CLLocationCoordinate2D(latitude: 39.9512865491707, longitude: -75.19780772808544)),
        PennEventLocation(name: "LGBT Center", coordinate: CLLocationCoordinate2D(latitude: 39.952134920208906, longitude: -75.20175623414063)),
        PennEventLocation(name: "Perry World House", coordinate: CLLocationCoordinate2D(latitude: 39.952830825368416, longitude: -75.19925550403856)),
        PennEventLocation(name: "Kelly Writers House", coordinate: CLLocationCoordinate2D(latitude: 39.95278713320119, longitude: -75.19955322954894)),
        PennEventLocation(name: "School of Veterinary Medicine", coordinate: CLLocationCoordinate2D(latitude: 39.95120312597537, longitude: -75.20003167095771)),
        
        // Misc Locations (East Campus)
        PennEventLocation(name: "Pottruck", coordinate: CLLocationCoordinate2D(latitude: 39.95389551832228, longitude: -75.19703789827587)),
        PennEventLocation(name: "Carey Law", coordinate: CLLocationCoordinate2D(latitude: 39.95383758745214, longitude: -75.19299154042018)),
        PennEventLocation(name: "Bookstore", coordinate: CLLocationCoordinate2D(latitude: 39.95350475759786, longitude: -75.19517843324019)),
        PennEventLocation(name: "Institute of Contemporary Art", coordinate: CLLocationCoordinate2D(latitude: 39.95436327421373, longitude: -75.19505476086994)),
        PennEventLocation(name: "Iron Gate Theater", coordinate: CLLocationCoordinate2D(latitude: 39.95466884060098, longitude: -75.19687205347438)),
        PennEventLocation(name: "ACME", coordinate: CLLocationCoordinate2D(latitude: 39.95444216235853, longitude: -75.20280520250788)),
        
        // Penn Park Area
        PennEventLocation(name: "Franklin Field", coordinate: CLLocationCoordinate2D(latitude: 39.95010688949503, longitude: -75.19005531281981)),
        PennEventLocation(name: "Palestra", coordinate: CLLocationCoordinate2D(latitude: 39.951445871860585, longitude: -75.18871232699556)),
        PennEventLocation(name: "Squash Center", coordinate: CLLocationCoordinate2D(latitude: 39.950602535549606, longitude: -75.18884481578563)),
        PennEventLocation(name: "Hutchinson Gymnasium", coordinate: CLLocationCoordinate2D(latitude: 39.95094695617954, longitude: -75.18871726462436)),
        PennEventLocation(name: "Class of 1923 Arena", coordinate: CLLocationCoordinate2D(latitude: 39.95172804969057, longitude: -75.18708421478526)),
        PennEventLocation(name: "Tennis Center", coordinate: CLLocationCoordinate2D(latitude: 39.95128649281696, longitude: -75.18745410501671)),
        PennEventLocation(name: "Shoemaker Green", coordinate: CLLocationCoordinate2D(latitude: 39.951420039967495, longitude: -75.18972518711035)),
        PennEventLocation(name: "Weightman Hall", coordinate: CLLocationCoordinate2D(latitude: 39.950680019914316, longitude: -75.19081291670771)),
        PennEventLocation(name: "Hamlin Tennis Courts", coordinate: CLLocationCoordinate2D(latitude: 39.949382998283426, longitude: -75.18756576066754)),
        PennEventLocation(name: "Park", coordinate: CLLocationCoordinate2D(latitude: 39.950090515315395, longitude: -75.18590146606591)),
        PennEventLocation(name: "Ace Adams Field", coordinate: CLLocationCoordinate2D(latitude: 39.95048076090068, longitude: -75.18502248861545)),
        PennEventLocation(name: "Cira Green", coordinate: CLLocationCoordinate2D(latitude: 39.95269047023988, longitude: -75.18334918497035)),
        PennEventLocation(name: "Franklin Building", coordinate: CLLocationCoordinate2D(latitude: 39.95328626963535, longitude: -75.19384130275887))
        
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


