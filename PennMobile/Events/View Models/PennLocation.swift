//
//  PennLocation.swift
//  PennMobile
//
//  Created by Jacky on 10/9/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI
import PennMobileShared

enum PennCoordinateScale: Double {
    case close = 150.0
    case mid = 300.0
    case far = 1000.0
}

struct PennLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

extension PennLocation {
    static let pennGSRLocation: [String: PennLocation] = [
            "Huntsman": PennLocation(name: "Huntsman", coordinate: CLLocationCoordinate2D(latitude: 39.95307761065585, longitude: -75.19817525836665)),
            "Academic Research": PennLocation(name: "ARB", coordinate: CLLocationCoordinate2D(latitude: 39.95129828577706, longitude: -75.19683445915696)),
            "Biotech Commons": PennLocation(name: "Biotech Commons", coordinate: CLLocationCoordinate2D(latitude: 39.9495964, longitude: -75.1982764)),
            "Education Commons": PennLocation(name: "Education Commons", coordinate: CLLocationCoordinate2D(latitude: 39.9504639, longitude: -75.1918546)),
            "Weigle": PennLocation(name: "Van Pelt Library", coordinate: CLLocationCoordinate2D(latitude: 39.952635958734824, longitude: -75.19344631852594)),
            "Levin Building": PennLocation(name: "Van Pelt Library", coordinate: CLLocationCoordinate2D(latitude: 39.952635958734824, longitude: -75.19344631852594)),
            "Lippincott": PennLocation(name: "Van Pelt Library", coordinate: CLLocationCoordinate2D(latitude: 39.952635958734824, longitude: -75.19344631852594)),
            "Van Pelt": PennLocation(name: "Van Pelt Library", coordinate: CLLocationCoordinate2D(latitude: 39.952635958734824, longitude: -75.19344631852594)),
            "Perelman Center": PennLocation(name: "PCPSE", coordinate: CLLocationCoordinate2D(latitude: 39.9534167, longitude: -75.1993981))
        ]
    
    static let pennEventLocations: [PennLocation] = [
        
        
        // Dorms / Dining
        PennLocation(name: "Harrison", coordinate: CLLocationCoordinate2D(latitude: 39.9519532049742, longitude: -75.20112202851995)),
        PennLocation(name: "Gutmann", coordinate: CLLocationCoordinate2D(latitude: 39.95378369040921, longitude: -75.20209860371801)),
        PennLocation(name: "Radian", coordinate: CLLocationCoordinate2D(latitude: 39.95426285980732, longitude: -75.20118913499053)),
        PennLocation(name: "Du Bois", coordinate: CLLocationCoordinate2D(latitude: 39.953729053974726, longitude: -75.20100366821694)),
        PennLocation(name: "Rodin", coordinate: CLLocationCoordinate2D(latitude: 39.953172783587675, longitude: -75.20134377744817)),
        PennLocation(name: "Gregory", coordinate: CLLocationCoordinate2D(latitude: 39.95284062848591, longitude: -75.2024690313161)),
        PennLocation(name: "Harnwell", coordinate: CLLocationCoordinate2D(latitude: 39.95238375805794, longitude: -75.20015674568795)),
        PennLocation(name: "Stouffer", coordinate: CLLocationCoordinate2D(latitude: 39.951618752554566, longitude: -75.20025454470158)),
        PennLocation(name: "Lauder", coordinate: CLLocationCoordinate2D(latitude: 39.95371471491931, longitude: -75.19129026404389)),
        PennLocation(name: "Hill", coordinate: CLLocationCoordinate2D(latitude: 39.95302883232131, longitude: -75.19067853565349)),
        PennLocation(name: "KCECH", coordinate: CLLocationCoordinate2D(latitude: 39.954270105221795, longitude: -75.19388456903467)),
        PennLocation(name: "Fisher", coordinate: CLLocationCoordinate2D(latitude: 39.950494278320406, longitude: -75.1978243723441)),
        PennLocation(name: "Ware", coordinate: CLLocationCoordinate2D(latitude: 39.95038566116001, longitude: -75.1965884401402)),
        PennLocation(name: "Riepe", coordinate: CLLocationCoordinate2D(latitude: 39.95024529610172, longitude: -75.19591924939768)),
        PennLocation(name: "Hillel", coordinate: CLLocationCoordinate2D(latitude: 39.95313114632822, longitude: -75.20004461654126)),
        PennLocation(name: "Chestnut Hall", coordinate: CLLocationCoordinate2D(latitude: 39.95500054995168, longitude: -75.20030364098739)),
        
        // Engineering
        PennLocation(name: "Moore", coordinate: CLLocationCoordinate2D(latitude: 39.95235195358212, longitude: -75.1905628341613)),
        PennLocation(name: "Levine", coordinate: CLLocationCoordinate2D(latitude: 39.9523636592379, longitude: -75.19108716260482)),
        PennLocation(name: "Wu and Chen", coordinate: CLLocationCoordinate2D(latitude: 39.9523636592379, longitude: -75.19108716260482)),
        PennLocation(name: "Skirkanich", coordinate: CLLocationCoordinate2D(latitude: 39.95203211923665, longitude: -75.19053972646232)),
        PennLocation(name: "Towne", coordinate: CLLocationCoordinate2D(latitude: 39.95176216372684, longitude: -75.19096291431735)),
        PennLocation(name: "Fisher-Bennett Hall", coordinate: CLLocationCoordinate2D(latitude: 39.95250634854153, longitude: -75.1918248868187)),
        PennLocation(name: "LRSM", coordinate: CLLocationCoordinate2D(latitude: 39.9529344527566, longitude: -75.18970192557583)),
        PennLocation(name: "Singh Center", coordinate: CLLocationCoordinate2D(latitude: 39.95290313241999, longitude: -75.18890554376047)),
        PennLocation(name: "DRL", coordinate: CLLocationCoordinate2D(latitude: 39.95193139049961, longitude: -75.18985605961376)),
        PennLocation(name: "Vagelos", coordinate: CLLocationCoordinate2D(latitude: 39.951324472746634, longitude: -75.19212315793388)),
        PennLocation(name: "Hayden Hall", coordinate: CLLocationCoordinate2D(latitude: 39.95130364421386, longitude: -75.19124840738166)),
        PennLocation(name: "Chem", coordinate: CLLocationCoordinate2D(latitude: 39.95080231715675, longitude: -75.1924193409095)),
        PennLocation(name: "Quain Courtyard", coordinate: CLLocationCoordinate2D(latitude: 39.952186767661445, longitude: -75.19087984244156)),
        PennLocation(name: "Morgan Building", coordinate: CLLocationCoordinate2D(latitude: 39.95192608237323, longitude: -75.1920054094594)),
        PennLocation(name: "Tangen", coordinate: CLLocationCoordinate2D(latitude: 39.955045, longitude: -75.202101)),
        
        // Wharton
        PennLocation(name: "Huntsman", coordinate: CLLocationCoordinate2D(latitude: 39.95307761065585, longitude: -75.19817525836665)),
        PennLocation(name: "ARB", coordinate: CLLocationCoordinate2D(latitude: 39.95129828577706, longitude: -75.19683445915696)),
        PennLocation(name: "Steinberg-Dietrich", coordinate: CLLocationCoordinate2D(latitude: 39.95189543035373, longitude: -75.19638290887475)),
        
        // College Green (Center of Campus)
        PennLocation(name: "Van Pelt Library", coordinate: CLLocationCoordinate2D(latitude: 39.952635958734824, longitude: -75.19344631852594)),
        PennLocation(name: "Meyerson", coordinate: CLLocationCoordinate2D(latitude: 39.95225671565781, longitude: -75.19267579780164)),
        PennLocation(name: "Fisher Fine Arts", coordinate: CLLocationCoordinate2D(latitude: 39.9517663757864, longitude: -75.19265233980819)),
        PennLocation(name: "Irvine", coordinate: CLLocationCoordinate2D(latitude: 39.950940871334346, longitude: -75.19298471927173)),
        PennLocation(name: "Houston", coordinate: CLLocationCoordinate2D(latitude: 39.95095210231154, longitude: -75.19383998394906)),
        PennLocation(name: "College Hall", coordinate: CLLocationCoordinate2D(latitude: 39.95153037060008, longitude: -75.19379532295793)),
        PennLocation(name: "Williams", coordinate: CLLocationCoordinate2D(latitude: 39.95094576807124, longitude: -75.1948119503)),
        PennLocation(name: "Claudia Cohen", coordinate: CLLocationCoordinate2D(latitude: 39.95139530994063, longitude: -75.19475231325019)),
        PennLocation(name: "Jaffe History of Art", coordinate: CLLocationCoordinate2D(latitude: 39.95273533555461, longitude: -75.1929464299296)),
        PennLocation(name: "Button", coordinate: CLLocationCoordinate2D(latitude: 39.95224256696289, longitude: -75.19370479455685)),
        PennLocation(name: "ARCH", coordinate: CLLocationCoordinate2D(latitude: 39.95226833804672, longitude: -75.19522519154951)),
        PennLocation(name: "Fagin", coordinate: CLLocationCoordinate2D(latitude: 39.94916855135187, longitude: -75.19601396188439)),
        PennLocation(name: "Biotech Commons", coordinate: CLLocationCoordinate2D(latitude: 39.949613882578554, longitude: -75.19568901147446)),
        PennLocation(name: "John Morgan", coordinate: CLLocationCoordinate2D(latitude: 39.94966434275017, longitude: -75.19674870191758)),
        PennLocation(name: "McNeil", coordinate: CLLocationCoordinate2D(latitude: 39.95199130686178, longitude: -75.19790657805316)),
        PennLocation(name: "Graduate School of Education", coordinate: CLLocationCoordinate2D(latitude: 39.9532241847759, longitude: -75.19719927300316)),
        PennLocation(name: "Annenberg Center", coordinate: CLLocationCoordinate2D(latitude: 39.9529727652777, longitude: -75.19646525419347)),
        PennLocation(name: "Annenberg School", coordinate: CLLocationCoordinate2D(latitude: 39.953001412780914, longitude: -75.19585568212437)),
        PennLocation(name: "Charles Addams Fine Arts", coordinate: CLLocationCoordinate2D(latitude: 39.9530180073702, longitude: -75.19518859805397)),
        
        // Misc Locations (West Campus)
        PennLocation(name: "Levin", coordinate: CLLocationCoordinate2D(latitude: 39.949548199883495, longitude: -75.19904304261793)),
        PennLocation(name: "Vance Hall", coordinate: CLLocationCoordinate2D(latitude: 39.9512865491707, longitude: -75.19780772808544)),
        PennLocation(name: "LGBT Center", coordinate: CLLocationCoordinate2D(latitude: 39.952134920208906, longitude: -75.20175623414063)),
        PennLocation(name: "Perry World House", coordinate: CLLocationCoordinate2D(latitude: 39.952830825368416, longitude: -75.19925550403856)),
        PennLocation(name: "Kelly Writers House", coordinate: CLLocationCoordinate2D(latitude: 39.95278713320119, longitude: -75.19955322954894)),
        PennLocation(name: "School of Veterinary Medicine", coordinate: CLLocationCoordinate2D(latitude: 39.95120312597537, longitude: -75.20003167095771)),
        
        // Misc Locations (East Campus)
        PennLocation(name: "Pottruck", coordinate: CLLocationCoordinate2D(latitude: 39.95389551832228, longitude: -75.19703789827587)),
        PennLocation(name: "Carey Law", coordinate: CLLocationCoordinate2D(latitude: 39.95383758745214, longitude: -75.19299154042018)),
        PennLocation(name: "Bookstore", coordinate: CLLocationCoordinate2D(latitude: 39.95350475759786, longitude: -75.19517843324019)),
        PennLocation(name: "Institute of Contemporary Art", coordinate: CLLocationCoordinate2D(latitude: 39.95436327421373, longitude: -75.19505476086994)),
        PennLocation(name: "Iron Gate Theater", coordinate: CLLocationCoordinate2D(latitude: 39.95466884060098, longitude: -75.19687205347438)),
        PennLocation(name: "ACME", coordinate: CLLocationCoordinate2D(latitude: 39.95444216235853, longitude: -75.20280520250788)),
        
        // Penn Park Area
        PennLocation(name: "Franklin Field", coordinate: CLLocationCoordinate2D(latitude: 39.95010688949503, longitude: -75.19005531281981)),
        PennLocation(name: "Palestra", coordinate: CLLocationCoordinate2D(latitude: 39.951445871860585, longitude: -75.18871232699556)),
        PennLocation(name: "Squash Center", coordinate: CLLocationCoordinate2D(latitude: 39.950602535549606, longitude: -75.18884481578563)),
        PennLocation(name: "Hutchinson Gymnasium", coordinate: CLLocationCoordinate2D(latitude: 39.95094695617954, longitude: -75.18871726462436)),
        PennLocation(name: "Class of 1923 Arena", coordinate: CLLocationCoordinate2D(latitude: 39.95172804969057, longitude: -75.18708421478526)),
        PennLocation(name: "Tennis Center", coordinate: CLLocationCoordinate2D(latitude: 39.95128649281696, longitude: -75.18745410501671)),
        PennLocation(name: "Shoemaker Green", coordinate: CLLocationCoordinate2D(latitude: 39.951420039967495, longitude: -75.18972518711035)),
        PennLocation(name: "Weightman Hall", coordinate: CLLocationCoordinate2D(latitude: 39.950680019914316, longitude: -75.19081291670771)),
        PennLocation(name: "Hamlin Tennis Courts", coordinate: CLLocationCoordinate2D(latitude: 39.949382998283426, longitude: -75.18756576066754)),
        PennLocation(name: "Penn Park", coordinate: CLLocationCoordinate2D(latitude: 39.950090515315395, longitude: -75.18590146606591)),
        PennLocation(name: "Ace Adams Field", coordinate: CLLocationCoordinate2D(latitude: 39.95048076090068, longitude: -75.18502248861545)),
        PennLocation(name: "Cira Green", coordinate: CLLocationCoordinate2D(latitude: 39.95269047023988, longitude: -75.18334918497035)),
        PennLocation(name: "Franklin Building", coordinate: CLLocationCoordinate2D(latitude: 39.95328626963535, longitude: -75.19384130275887))
    ]
    
    static let fitnessLocations: [PennLocation] = [
        PennLocation(name: "Pottruck", coordinate: CLLocationCoordinate2D(latitude: 39.95389551832228, longitude: -75.19703789827587)),
        PennLocation(name: "Fox", coordinate: CLLocationCoordinate2D(latitude: 39.950343, longitude: -75.189154)),
        PennLocation(name: "Climbing", coordinate: CLLocationCoordinate2D(latitude: 39.954034, longitude: -75.196960)),
        PennLocation(name: "Membership", coordinate: CLLocationCoordinate2D(latitude: 39.954057, longitude: -75.197188)),
        PennLocation(name: "Ringe", coordinate: CLLocationCoordinate2D(latitude: 39.950450, longitude: -75.188642)),
        PennLocation(name: "Rockwell", coordinate: CLLocationCoordinate2D(latitude: 39.953859, longitude: -75.196868)),
        PennLocation(name: "Sheerr", coordinate: CLLocationCoordinate2D(latitude: 39.953859, longitude: -75.196868))
    ]
    
    static let diningLocations: [Int: CLLocationCoordinate2D] = [
        // 1920 Commons
        593: CLLocationCoordinate2D(latitude: 39.952275, longitude: -75.199560),
        // Hill House
        636: CLLocationCoordinate2D(latitude: 39.953040, longitude: -75.190589),
        // English House
        637: CLLocationCoordinate2D(latitude: 39.954242, longitude: -75.194351),
        // Falk Kosher Dining
        638: CLLocationCoordinate2D(latitude: 39.953117, longitude: -75.200075),
        // Houston Market
        639: CLLocationCoordinate2D(latitude: 39.950920, longitude: -75.193892),
        // Accenture Café
        641: CLLocationCoordinate2D(latitude: 39.951827, longitude: -75.191315),
        // Joe's Café
        642: CLLocationCoordinate2D(latitude: 39.951818, longitude: -75.196089),
        // Lauder College House
        1442: CLLocationCoordinate2D(latitude: 39.953907, longitude: -75.191733),
        // McClelland Express
        747: CLLocationCoordinate2D(latitude: 39.950378, longitude: -75.197151),
        // 1920 Gourmet Grocer
        1057: CLLocationCoordinate2D(latitude: 39.952115, longitude: -75.199492),
        // 1920 Starbucks
        1163: CLLocationCoordinate2D(latitude: 39.952361, longitude: -75.199466),
        // LCH Retail
        1731: CLLocationCoordinate2D(latitude: 39.953907, longitude: -75.191733),
        // Pret a Manger MBA
        1732: CLLocationCoordinate2D(latitude: 39.952591, longitude: -75.198326),
        // Pret a Manger Locust Walk
        1733: CLLocationCoordinate2D(latitude: 39.952591, longitude: -75.198326)
    ]
}

extension PennLocation {
    static let collegeHall: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 39.9522, longitude: -75.1932)
    
    static var defaultLocation: CLLocationCoordinate2D {
        collegeHall
    }
    
    static var defaultRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: collegeHall,
            span: MKCoordinateSpan(latitudeDelta: 0.0020, longitudeDelta: 0.0020)
        )
    }

    static func getDefaultRegion(at scale: PennCoordinateScale) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: defaultLocation, latitudinalMeters: scale.rawValue, longitudinalMeters: scale.rawValue)
    }

    static func getCoordinates(for dining: DiningVenue) -> CLLocationCoordinate2D {
        // first fetches through the penn event locaitons
        if let matchingLocation = PennLocation.pennEventLocations.first(where: { $0.name.lowercased() == dining.name.lowercased() }) {
            return matchingLocation.coordinate
        }

        // else fallback to original coordinates from PennCoordinate if not found
        return PennLocation.diningLocations[dining.id] ?? PennLocation.defaultLocation
    }

    static func getRegion(for dining: DiningVenue, at scale: PennCoordinateScale) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: getCoordinates(for: dining), latitudinalMeters: scale.rawValue, longitudinalMeters: scale.rawValue)
    }
    
    // MARK: - event location fetching from PennLocation

    static func coordinateForEvent(location: String, eventName: String, eventType: String) -> (coordinate: CLLocationCoordinate2D?, isVirtual: Bool) {
        
        // first check for virtual / zoom, if so dont show map
        let virtualKeywords = ["virtual", "online", "zoom", "microsoft teams", "google meet", "webex"]
        // this is just for SF wharton rn in venture lab but can be dynamically changed later on to handle other cases where we don't want to show map but it's not virtual
        let other = ["san francisco"]
        let locationLowercased = location.lowercased()
        for keyword in virtualKeywords {
            if locationLowercased.contains(keyword) {
                print("Event is virtual: \(location)")
                return (nil, true)
            }
        }
        for keyword in other {
            if locationLowercased.contains(keyword) {
                print("Event is NOT virtual but no location: \(location)")
                return (nil, false)
            }
        }
        
        // process string and find coordinate method
        func findCoordinate(from string: String) -> CLLocationCoordinate2D? {
            let parts = string.lowercased().split(separator: " ").map(String.init)
            for part in parts {
                if let matchingLocation = PennLocation.pennEventLocations.first(where: { $0.name.lowercased().contains(part) }) {
                    print("Matching \(part): '\(part)' with location '\(matchingLocation.name)'")
                    return matchingLocation.coordinate
                }
            }
            print("No match found in \(string) for string: \(string)")
            return nil
        }

        // check in the order: eventType, location, eventName
        if let coordinate = findCoordinate(from: eventType) {
            return (coordinate, false)
        }
        if location.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() != "no location" {
            if let coordinate = findCoordinate(from: location) {
                return (coordinate, false)
            }
        }
        if let coordinate = findCoordinate(from: eventName) {
            return (coordinate, false)
        }
        
        // default to nil to hide map
        return (nil, false)
    }
}
