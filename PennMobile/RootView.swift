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
    @BackendFetched(PennMobileApplication.Dining.GetVenues()) var venues: BackendFetchedResult<[DiningVenue], Error>
    
    var body: some View {
        if platform.isLoggedIn {
            VStack {
                Text("Logged In!")
                Button("Log Out") {
                    platform.logoutPlatform()
                }
                Button("Refresh Venues") {
                    Task {
                        await $venues.refresh()
                    }
                }
                if case .success(let values) = venues {
                    ForEach(values) { el in
                        Text(el.name)
                    }
                }
            }
        } else {
            LoggedOutView()
        }
    }
}
