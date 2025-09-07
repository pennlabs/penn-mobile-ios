//
//  GSRGuestLandingPage.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/6/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import MapKit
import LabsPlatformSwift

struct GSRGuestLandingPage: View {
    static let latOffset = 0.00005
    static let longOffset = 0.0
    
    @State var locations: [GSRLocation] = []
    @State var selectedLocation: GSRLocation? = nil
    @State var position: MapCameraPosition = .automatic

    var body: some View {
        ZStack {
            Map(position: $position)
                .mapStyle(.standard(pointsOfInterest: .including(.library)))
                .allowsHitTesting(false)
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    if selectedLocation != nil {
                        AsyncImage(url: URL(string: selectedLocation!.imageUrl)) { result in
                            result.image?
                                .resizable()
                                .scaledToFit()
                            
                        }
                        Rectangle()
                            .frame(maxHeight: 56)
                            .foregroundStyle(.thickMaterial)
                            .overlay {
                                Text(selectedLocation!.name)
                                    .font(.title)
                                    .bold()
                            }
                        
                    }
                }
                .clipShape(.rect(cornerRadius: 36))
                .padding(.horizontal, 48)
                .padding(.vertical, 16)
                .shadow(radius: 4)
            }
            
            
            LinearGradient(colors: [.black, .black.opacity(0.8), .clear, .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 8) {
                Text("Group Study Rooms")
                    .font(.largeTitle)
                    .bold()
                Text("Book with ease using Penn Mobile!")
                    .font(.headline)
                    .padding(.bottom, 48)
                Text("Sign in to use GSR Booking")
                    .italic()
                Button {
                    LabsPlatform.shared?.loginWithPlatform()
                } label: {
                    Text("Sign In")
                        .foregroundStyle(.background)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .frame(maxWidth: 150, maxHeight: 50)
                Spacer()
            }
            .padding(.vertical, 16)
            .foregroundStyle(.white)
        }
        
        .onAppear {
            Task {
                let request = URLRequest(url: URL(string: "https://pennmobile.org/api/gsr/locations/")!)
                guard let (data, _) = try? await URLSession.shared.data(for: request) else {
                    return
                }
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if let loc = try? decoder.decode([GSRLocation].self, from: data) {
                    locations = loc
                    selectedLocation = locations.randomElement()
                }
            }
        }
        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
            if !locations.isEmpty {
                withAnimation(.easeInOut(duration: 0.5)) {
                    selectedLocation = locations.randomElement()
                }
            }
        }
        .onChange(of: selectedLocation) {
            guard let selectedLocation, let loc = PennLocation.pennGSRLocation[selectedLocation.name] else {
                position = .automatic
                return
            }
            
            withAnimation {
                position = .camera(MapCamera (
                    centerCoordinate: CLLocationCoordinate2D(
                        latitude: loc.coordinate.latitude + GSRGuestLandingPage.latOffset,
                        longitude: loc.coordinate.longitude + GSRGuestLandingPage.longOffset
                    ),
                    distance: 750,
                    pitch: 50
                )
                )
            }
        }
    }
}

#Preview {
    GSRGuestLandingPage()
}
