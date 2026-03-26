//
//  GSRMapSectionView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 3/26/26.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import MapKit

struct GSRMapSectionView: View {
    let model: GSRReservation
    let gsrLocation: String
    let roomName: String?
    
    @State var position: MapCameraPosition = .automatic
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location").font(.headline)

            if let coordinate = PennLocation.pennGSRLocation[gsrLocation]?.coordinate {
                Map(position: $position) {
                    UserAnnotation()
                    Marker("\(model.gsr.name), \(roomName ?? model.roomName)", coordinate: coordinate)
                }
                .frame(height: 240)
                .cornerRadius(12)
                .onAppear {
                    position = .region(MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    ))
                }
            } else {
                HStack {
                    Image(systemName: "mappin.slash")
                    Text("Location not available")
                        .font(.subheadline)
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, minHeight: 80)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
}
