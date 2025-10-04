//
//  GSRMapView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 10/3/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import MapKit

struct GSRMapView : View {
    @EnvironmentObject var vm: GSRViewModel
    
    @State var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.952468, longitude: -75.198336),
            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        )
    )
    
    var body : some View {
        
        Map(position: $position)
            .ignoresSafeArea(.all)
    }
}
