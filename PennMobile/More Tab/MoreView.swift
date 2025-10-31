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

private struct PennLink: View, Identifiable {
    let title: LocalizedStringKey
    let url: URL
    
    init(title: LocalizedStringKey, url: URL) {
        self.title = title
        self.url = url
    }
    
    init(title: LocalizedStringKey, url: String) {
        self.title = title
        self.url = URL(string: url)!
    }
    
    var id: URL {
        url
    }
    
    var body: some View {
        Link(title, destination: url)
    }
}

let feedbackURL = URL(string: "https://pennlabs.org/feedback/ios")!

private let pennLinks: [PennLink] = [
    PennLink(title: "Penn Labs", url: "https://pennlabs.org"),
    PennLink(title: "Share Your Feedback", url: feedbackURL)]

struct MoreView: View {
    var features: [AppFeature]
    
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var bannerViewModel: BannerViewModel
    
    @State var isLoggingOut = false
    
    var body: some View {
        List {
            Section {
                if case .loggedIn(let account) = authManager.state {
                    NavigationLink {
                        AppFeature.ViewControllerView<ProfilePageViewController>()
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationTitle("Profile")
                    } label: {
                        ProfileRowView(account: account)
                    }
                    
                    NavigationLink("Privacy") {
                        AppFeature.ViewControllerView<PrivacyViewController>()
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationTitle("Privacy")
                    }
                    
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
                } else {
                    Button {
                        LabsPlatform.shared?.loginWithPlatform()
                    } label: {
                        ProfileRowView(account: nil)
                    }
                }
            } header: {
                Text("Account")
            }
            
            if FeatureFlags.shared.showFeatureFlagSettings {
                Section {
                    NavigationLink("Feature Flags") {
                        FeatureFlagSettingsView()
                    }
                } header: {
                    Text("Development")
                }
            }
            
            if FeatureFlags.shared.showAuthSettings {
                Section {
                    Button("Force Refresh and Quit") {
                        LabsPlatform.shared?.debugForceRefresh()
                        DispatchQueue.main.schedule(after: .init(.now().advanced(by: /*.seconds(20)*/ .milliseconds(500)))) {
                            exit(0)
                        }
                    }
                    Button("Force Refresh Now") {
                        LabsPlatform.shared?.debugForceRefresh()
                    }
                } header: {
                    Text("Auth")
                }
            }
            
            Section {
                HStack {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80, maximum: 120), alignment: .top)], spacing: 16) {
                        ForEach(features) { feature in
                            Button {
                                navigationManager.path.append(feature.id)
                            } label: {
                                VStack {
                                    feature.image
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .padding(12)
                                        .background(feature.color)
                                        .clipShape(.rect(cornerRadius: 8))
                                        .environment(\.colorScheme, .dark)
                                    (
                                        Text(feature.longName) +
                                        Text("\u{00a0}\(Image(systemName: "chevron.forward"))").foregroundColor(.secondary)
                                    ).font(.caption)
                                }
                            }
                            .tint(.primary)
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                .padding(.vertical, 16)
                
                Button("Edit Tab Bar...") {
                    navigationManager.isConfiguringTabs = true
                }
            } header: {
                Text("Features")
            }
            
            Section {
                ForEach(pennLinks) { link in
                    link
                }
            } header: {
                Text("Links")
            }
            
            if Account.current?.pennid == 12345678 {
                Section {
                    Toggle(isOn: $bannerViewModel.showBanners) {
                        Text("Force April Fools")
                    }
                } header: {
                    Text("Debugging")
                }
            }
        }
        .navigationTitle(Text("More"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(Text("Are you sure you want to log out?"), isPresented: $isLoggingOut) {
            Button(role: .cancel) {
                isLoggingOut = false
            } label: {
                Text("Cancel")
            }
            
            Button(role: .destructive) {
                authManager.logOut()
            } label: {
                Text("Log Out")
            }
        } message: {
            Text("Your user data will be removed from this device.")
        }
    }
}
