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

class PennLocation {
    static let shared = PennLocation()

    // MARK: - default coordiantes from PennCoordinate

    // college hall
    let collegeHall: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 39.9522, longitude: -75.1932)

    func getDefault() -> CLLocationCoordinate2D {
        return collegeHall
    }

    func getDefaultRegion(at scale: PennCoordinateScale) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: getDefault(), latitudinalMeters: scale.rawValue, longitudinalMeters: scale.rawValue)
    }

    // MARK: - penn event location(s)
    struct PennEventLocation: Identifiable {
        let id = UUID()
        let name: String
        let coordinate: CLLocationCoordinate2D
    }

    let pennEventLocations: [PennEventLocation] = [
        
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
        PennEventLocation(name: "Wu and Chen", coordinate: CLLocationCoordinate2D(latitude: 39.9523636592379, longitude: -75.19108716260482)),
        PennEventLocation(name: "Skirkanich", coordinate: CLLocationCoordinate2D(latitude: 39.95203211923665, longitude: -75.19053972646232)),
        PennEventLocation(name: "Towne", coordinate: CLLocationCoordinate2D(latitude: 39.95176216372684, longitude: -75.19096291431735)),
        PennEventLocation(name: "Fisher-Bennett Hall", coordinate: CLLocationCoordinate2D(latitude: 39.95250634854153, longitude: -75.1918248868187)),
        PennEventLocation(name: "LRSM", coordinate: CLLocationCoordinate2D(latitude: 39.9529344527566, longitude: -75.18970192557583)),
        PennEventLocation(name: "Singh Center", coordinate: CLLocationCoordinate2D(latitude: 39.95290313241999, longitude: -75.18890554376047)),
        PennEventLocation(name: "DRL", coordinate: CLLocationCoordinate2D(latitude: 39.95193139049961, longitude: -75.18985605961376)),
        PennEventLocation(name: "Vagelos", coordinate: CLLocationCoordinate2D(latitude: 39.951324472746634, longitude: -75.19212315793388)),
        PennEventLocation(name: "Hayden Hall", coordinate: CLLocationCoordinate2D(latitude: 39.95130364421386, longitude: -75.19124840738166)),
        PennEventLocation(name: "Chem", coordinate: CLLocationCoordinate2D(latitude: 39.95080231715675, longitude: -75.1924193409095)),
        PennEventLocation(name: "Quain Courtyard", coordinate: CLLocationCoordinate2D(latitude: 39.952186767661445, longitude: -75.19087984244156)),
        PennEventLocation(name: "Morgan Building", coordinate: CLLocationCoordinate2D(latitude: 39.95192608237323, longitude: -75.1920054094594)),
        PennEventLocation(name: "Tangen", coordinate: CLLocationCoordinate2D(latitude: 39.955045, longitude: -75.202101)),

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
        PennEventLocation(name: "Penn Park", coordinate: CLLocationCoordinate2D(latitude: 39.950090515315395, longitude: -75.18590146606591)),
        PennEventLocation(name: "Ace Adams Field", coordinate: CLLocationCoordinate2D(latitude: 39.95048076090068, longitude: -75.18502248861545)),
        PennEventLocation(name: "Cira Green", coordinate: CLLocationCoordinate2D(latitude: 39.95269047023988, longitude: -75.18334918497035)),
        PennEventLocation(name: "Franklin Building", coordinate: CLLocationCoordinate2D(latitude: 39.95328626963535, longitude: -75.19384130275887))
    ]

    // MARK: - dining coordinates from PennCoordinate and its fetch coordinates func

    func getCoordinates(for dining: DiningVenue) -> CLLocationCoordinate2D {
        
        // first fetches through the penn event locaitons
        if let matchingLocation = pennEventLocations.first(where: { $0.name.lowercased() == dining.name.lowercased() }) {
            return matchingLocation.coordinate
        }

        // else fallback to original coordinates from PennCoordinate if not found
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
            // Accenture Café
            return CLLocationCoordinate2D(latitude: 39.951827, longitude: -75.191315)
        case 642:
            // Joe's Café
            return CLLocationCoordinate2D(latitude: 39.951818, longitude: -75.196089)
        case 1442:
            // Lauder College House
            return CLLocationCoordinate2D(latitude: 39.953907, longitude: -75.191733)
        case 747:
            // McClelland Express
            return CLLocationCoordinate2D(latitude: 39.950378, longitude: -75.197151)
        case 1057:
            // 1920 Gourmet Grocer
            return CLLocationCoordinate2D(latitude: 39.952115, longitude: -75.199492)
        case 1163:
            // 1920 Starbucks
            return CLLocationCoordinate2D(latitude: 39.952361, longitude: -75.199466)
        case 1731:
            // LCH Retail
            return CLLocationCoordinate2D(latitude: 39.953907, longitude: -75.191733)
        case 1732:
            // Pret a Manger MBA
            return CLLocationCoordinate2D(latitude: 39.952591, longitude: -75.198326)
        case 1733:
            // Pret a Manger Locust Walk
            return CLLocationCoordinate2D(latitude: 39.952591, longitude: -75.198326)
        default:
            // defautlt to college hall
            return getDefault()
        }
    }

    func getRegion(for dining: DiningVenue, at scale: PennCoordinateScale) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: getCoordinates(for: dining), latitudinalMeters: scale.rawValue, longitudinalMeters: scale.rawValue)
    }

    // MARK: - event location fetching from PennEventLocation

    func coordinateForEvent(location: String, eventName: String, eventType: String) -> (coordinate: CLLocationCoordinate2D?, isVirtual: Bool) {
        
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
                if let matchingLocation = pennEventLocations.first(where: { $0.name.lowercased().contains(part) }) {
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

        // default to philadelphia coords if not
//        return CLLocationCoordinate2D(latitude: 39.9522, longitude: -75.1932)
        
        // default to nil to hide map
        return (nil, false)
        
    }

    // MARK: - previous commented out code in PennCoordinate (Fitness Facilities, if needed)

    // Keeping for future reference!
//    func getCoordinates(for facility: FitnessFacilityName) -> CLLocationCoordinate2D {
//        switch facility {
//        case .pottruck:
//            return CLLocationCoordinate2D(latitude: 39.953562, longitude: -75.197002)
//        case .fox:
//            return CLLocationCoordinate2D(latitude: 39.950343, longitude: -75.189154)
//        case .climbing:
//            return CLLocationCoordinate2D(latitude: 39.954034, longitude: -75.196960)
//        case .membership:
//            return CLLocationCoordinate2D(latitude: 39.954057, longitude: -75.197188)
//        case .ringe:
//            return CLLocationCoordinate2D(latitude: 39.950450, longitude: -75.188642)
//        case .rockwell:
//            return CLLocationCoordinate2D(latitude: 39.953859, longitude: -75.196868)
//        case .sheerr:
//            return CLLocationCoordinate2D(latitude: 39.953859, longitude: -75.196868)
//        case .unknown:
//            return getDefault()
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
//        return MKCoordinateRegion(center: getCoordinates(for: facility), latitudinalMeters: scale.rawValue, longitudinalMeters: scale.rawValue)
//    }
    
}
