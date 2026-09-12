//
//  RootView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI
import LabsPlatformSwift
import PennMobileShared


struct RootView: View {
    @EnvironmentObject var platform: LabsPlatform
    @State var venues: [DiningVenue] = []
    
    var body: some View {
        if platform.isLoggedIn {
            VStack {
                Text("Logged In!")
                Button("Log Out") {
                    platform.logoutPlatform()
                }
                Button("Fetch") {
                    Task {
                        let venues = try? await PennMobileBackend.executeEndpoint(PennMobileApplication.Dining.GetVenues())
                        self.venues = venues ?? []
                    }
                }
                ForEach(venues) { el in
                    Text(el.name)
                }
            }
        } else {
            LoggedOutView()
        }
    }
}
