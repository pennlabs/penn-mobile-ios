//
//  MoreView.swift
//  PennMobile
//
//  Created by Anthony Li on 10/5/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

private struct PennLink: View, Identifiable {
    let title: LocalizedStringKey
    let url: URL
    
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

private let pennLinks: [PennLink] = [
    PennLink(title: "Penn Labs", url: "https://pennlabs.org"),
    PennLink(title: "Share Your Feedback", url: "https://airtable.com/shrS98E3rj5Nw1wy6")]

struct MoreView: View {
    var features: [AppFeature]
    
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var mainTabViewCoordinator: MainTabViewCoordinator
    
    @State var path = NavigationPath()
    @State var isPresentingLoginSheet = false
    @State var isLoggingOut = false
    
    var body: some View {
        NavigationStack(path: $path) {
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
                            isPresentingLoginSheet = true
                        } label: {
                            ProfileRowView(account: nil)
                        }
                    }
                } header: {
                    Text("Account")
                }
                
                Section {
                    HStack {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80, maximum: 120), alignment: .top)], spacing: 16) {
                            ForEach(features) { feature in
                                Button {
                                    path.append(feature.id)
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
                        mainTabViewCoordinator.isConfiguringTabs = true
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
            }
            .navigationTitle(Text("More"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: FeatureIdentifier.self) { id in
                AnyView(features.first { $0.id == id }!.content)
            }
            .sheet(isPresented: $isPresentingLoginSheet) {
                LabsLoginView { success in
                    if success {
                        authManager.determineInitialState()
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
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
}
