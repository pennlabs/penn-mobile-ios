//
//  MyListingsActivity.swift
//  PennMobile
//
//  Created by Jordan H on 2/03/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import PennMobileShared
import SwiftUI

struct MyListingsActivity: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var sublettingViewModel: SublettingViewModel
    private var isListings: Bool
    @State private var selectedTab: SublettingViewModel.ListingsTabs
    @State private var showLoginAlert: Bool
    
    public init(isListings: Bool = false) {
        self.isListings = isListings
        self._selectedTab = State(initialValue: isListings ? .posted : .saved)
        self._showLoginAlert = State(initialValue: !Account.isLoggedIn)
    }
    
    var body: some View {
        VStack {
            Picker("Tab", selection: $selectedTab.animation()) {
                if isListings {
                    Text("Posted").tag(SublettingViewModel.ListingsTabs.posted)
                    Text("Drafts").tag(SublettingViewModel.ListingsTabs.drafts)
                } else {
                    Text("Saved").tag(SublettingViewModel.ListingsTabs.saved)
                    Text("Applied").tag(SublettingViewModel.ListingsTabs.applied)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            TabView(selection: $selectedTab) {
                // Posted tab
                ScrollView {
                    VStack {
                        NavigationLink(value: SublettingPage.newListingForm) {
                            AddSubletView()
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                        
                        ForEach(sublettingViewModel.listings) { sublet in
                            NavigationLink(value: SublettingPage.subletDetailView(sublet.subletID)) {
                                SubletDisplayRow(sublet: sublet)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .tag(SublettingViewModel.ListingsTabs.posted)
                
                // Drafts tab
                ScrollView {
                    VStack {
                        NavigationLink(value: SublettingPage.newListingForm) {
                            AddSubletView()
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                        
                        ForEach(sublettingViewModel.drafts) { sublet in
                            NavigationLink(value: SublettingPage.editSubletView) {
                                SubletDisplayRow(sublet: sublet)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .tag(SublettingViewModel.ListingsTabs.drafts)
                
                // Saved tab
                ScrollView {
                    if sublettingViewModel.saved.count > 0 {
                        VStack {
                            ForEach(sublettingViewModel.saved) { sublet in
                                NavigationLink(value: SublettingPage.subletDetailView(sublet.subletID)) {
                                    SubletDisplayRow(sublet: sublet)
                                        .padding(.horizontal)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    } else {
                        Text("No saved sublets!")
                            .foregroundStyle(.tertiary)
                            .font(.subheadline)
                    }
                }
                .tag(SublettingViewModel.ListingsTabs.saved)
                
                // Applied tab
                ScrollView {
                    if sublettingViewModel.applied.count > 0 {
                        VStack {
                            ForEach(sublettingViewModel.applied) { sublet in
                                NavigationLink(value: SublettingPage.subletDetailView(sublet.subletID)) {
                                    SubletDisplayRow(sublet: sublet)
                                        .padding(.horizontal)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    } else {
                       Text("No applied sublets!")
                           .foregroundStyle(.tertiary)
                           .font(.subheadline)
                   }
                }
                .tag(SublettingViewModel.ListingsTabs.applied)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .navigationTitle(isListings ? "My Listings" : "My Activity")
        .toolbar {
            if isListings {
                ToolbarItem {
                    NavigationLink(value: SublettingPage.newListingForm) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(Text("New Listing"))
                }
            }
        }
        .alert(isPresented: $showLoginAlert) {
            Alert(title: Text("You must log in to access this feature."), message: Text("Please login on the \"More\" tab."), dismissButton: .default(Text("Ok"), action: { navigationManager.path.removeLast() }))
        }
    }
}

#Preview {
    MyListingsActivity(isListings: true)
}
