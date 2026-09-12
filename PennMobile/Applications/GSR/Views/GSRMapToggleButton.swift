//
//  GSRMapToggleButton.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 2/19/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRMapToggleButton: View {
    @Binding var isMapView: Bool
    
    var body: some View {
        Button {
            isMapView.toggle()
        } label: {
            Label {
                Text(isMapView ? "List View" : "Map View")
            } icon: {
                Image(systemName: isMapView ? "list.bullet" : "map.fill")
            }
            .contentTransition(.symbolEffect(.replace))
            .animation(.snappy, value: isMapView)
            .frame(minWidth: 125, minHeight: 20, alignment: .center)
            .padding(.horizontal, 12.5)
            .padding(.vertical, 14)
        }
        .buttonStyle(MapViewButtonStyle())
    }
}
