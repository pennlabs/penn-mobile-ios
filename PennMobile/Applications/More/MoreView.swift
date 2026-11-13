//
//  MoreView.swift
//  PennMobile
//
//  Created by Anthony Li on 10/5/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import LabsPlatformSwift
import PennMobileShared

private struct PennLink: Identifiable {
    let title: LocalizedStringKey
    let url: URL

    var id: URL { url }
}

private let pennLinks: [PennLink] = [
    PennLink(title: "Penn Labs", url: URL(string: "https://pennlabs.org")!),
    PennLink(title: "Share Your Feedback", url: URL(string: "https://pennlabs.org/feedback/ios")!)
]

struct MoreView: View {
    let features: [AppFeature]

    @State var isLoggingOut = false

    var body: some View {
        NavigationStack {
            List {
                let incidents = IncidentsViewModel.shared.incidents
                if !incidents.isEmpty {
                    Section {
                        ForEach(incidents) { incident in
                            IncidentView(incident: incident)
                        }
                    } header: {
                        Text("Service Incidents")
                    }
                }

                Section {
                    if let account = PennMobileAuthManager.shared.account.unwrap() {
                        NavigationLink {
                            ProfileView(account: account) {
                                await PennMobileAuthManager.shared.refreshAccount()
                            }
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationTitle("Profile")
                        } label: {
                            ProfileRowView(account: account)
                        }
                    } else {
                        ProfileRowView(account: nil)
                    }

                    // TODO: Privacy, once PrivacyPreference and its data sources are ported

                    NavigationLink("Notifications") {
                        NotificationsView()
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationTitle("Notifications")
                    }

                    Button(role: .destructive) {
                        isLoggingOut = true
                    } label: {
                        Text("Log Out...")
                    }
                } header: {
                    Text("Account")
                }

                // TODO: Development section with Feature Flags, once FeatureFlags is ported

                #if DEBUG
                Section {
                    Button("Force Refresh and Quit") {
                        LabsPlatform.shared?.debugForceRefresh()
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                            exit(0)
                        }
                    }
                    Button("Force Refresh Now") {
                        LabsPlatform.shared?.debugForceRefresh()
                    }
                } header: {
                    Text("Auth")
                }
                #endif

                if !features.isEmpty {
                    Section {
                        FeatureGridView(features: features)
                        // TODO: Edit Tab Bar, once the tab list is configurable
                    } header: {
                        Text("Features")
                    }
                }

                Section {
                    ForEach(pennLinks) { link in
                        Link(link.title, destination: link.url)
                    }
                } header: {
                    Text("Links")
                }
            }
            .navigationTitle(Text("More"))
            .navigationBarTitleDisplayMode(.inline)
            .alert(Text("Are you sure you want to log out?"), isPresented: $isLoggingOut) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    LabsPlatform.shared?.logoutPlatform()
                }
            } message: {
                Text("Your user data will be removed from this device.")
            }
        }
    }
}
