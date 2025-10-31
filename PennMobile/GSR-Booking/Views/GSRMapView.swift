//
//  GSRMapView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 10/3/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation

struct GSRMapView : View {
    @EnvironmentObject var vm: GSRViewModel
    @Binding var selectedTab: GSRTab
    
    @State var selectedLocation: GSRLocation? = nil
    @State var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.952468, longitude: -75.198336),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    )
    
    private let locationManager = CLLocationManager()
    
    var body : some View {
        Map(position: $position) {
            UserAnnotation()
            ForEach(vm.availableLocations.standardGSRSort, id: \.self) { location in
                if let loc = PennLocation.pennGSRLocation[location.name] {
                    Annotation("", coordinate: loc.coordinate) {
                        NavigationLink(value: location) {
                            VStack(spacing: 4) {
                                AsyncImage(url: URL(string: location.imageUrl)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 45, height: 45)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
             
                                Text(location.name)
                                    .font(.caption2.weight(.semibold))
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .contentShape(Rectangle())
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(8)
                                    .frame(maxWidth: 100)
                            }
                            .shadow(radius: 2)
                            .padding(1)
                            .frame(maxWidth: 100, maxHeight: 50)
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
        .navigationDestination(for: GSRLocation.self) { loc in
            GSRBookingView(centralTab: $selectedTab, selectedLocInternal: loc)
                .frame(width: UIScreen.main.bounds.width)
                .environmentObject(vm)
        }
        .transition(.blurReplace)
    }
}



