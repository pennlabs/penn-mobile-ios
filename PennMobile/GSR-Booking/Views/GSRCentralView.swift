//
//  GSRCentralView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 2/19/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRCentralView: View {
    
    @State var loggedIn = true
    private var locationModel = GSRLocationModel.shared
    @State private var locations = [GSRLocation]()
    @State private var selectedTab : String = "Book"
    private let tabs = ["Book", "Reservations"]
    
    init(){
        locationModel.prepare()
    }
    var body: some View {
        if loggedIn {
            NavigationView {
                VStack {
                    Picker("Select", selection: $selectedTab) {
                        ForEach(tabs, id: \.self) { tab in
                            Text(tab).tag(tab)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.top, 0)
                    
                    if selectedTab == "Book" {
                        List(locationModel.getLocations(), id: \.lid) { location in
                            NavigationLink(destination: EmptyFile()) {
                                GSRLocationCell(location: location)
                                .frame(maxHeight: .infinity)
                            }
                            .listRowBackground(Color.black)
                        }
                        .listStyle(PlainListStyle())
                    } else {
                        Text("No current GSR Reservations")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                .onAppear {
                    locationModel.prepare()
                }
            }
            .navigationTitle("GSR Booking")
            .navigationBarTitleDisplayMode(.inline)
        } else {
            GSRGuestLandingPage()
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    GSRCentralView()
}
