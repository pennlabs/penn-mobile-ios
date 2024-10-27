//
//  AddressMapView.swift
//  PennMobile
//
//  Created by Jordan H on 3/2/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import MapKit

struct AddressMapView: View {
    var address: String?
    @State private var region: MKCoordinateRegion = PennLocation.shared.getDefaultRegion(at: .far)
    @State private var location: CLLocationCoordinate2D?

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: location != nil ? [location!] : []) { location in
            MapMarker(coordinate: location)
        }
        .onAppear {
            if address != nil {
                let geocoder = CLGeocoder()
                let regionHint = CLCircularRegion(center: region.center, radius: 5000, identifier: "regionHint")
                geocoder.geocodeAddressString(address!, in: regionHint) { (placemarks, _) in
                    if let placemark = placemarks?.first, let location = placemark.location {
                        self.region.center = location.coordinate
                        self.location = location.coordinate
                    }
                }
            }
        }
    }
}

#Preview {
    AddressMapView(address: "101 S 39th St")
}
