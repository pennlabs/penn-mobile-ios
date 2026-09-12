//
//  GSRMapView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 10/3/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import MapKit
import PennMobileShared

struct GSRMapView: View {
    let locations: [GSRLocation]
    
    @State private var locationManager = CLLocationManager()
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.952468, longitude: -75.198336),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    )
    
    var body: some View {
        Map(position: $position) {
            UserAnnotation()
            ForEach(locations, id: \.self) { location in
                if let pennLocation = PennLocation.pennGSRLocation[location.name] {
                    Annotation("", coordinate: pennLocation.coordinate) {
                        NavigationLink(value: location) {
                            GSRMapAnnotationLabel(location: location)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .transition(.blurReplace)
    }
}
