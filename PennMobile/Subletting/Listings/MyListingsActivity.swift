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
    @Environment(\.dismiss) var dismiss
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
                        NavigationLink(destination: NewListingForm()) {
                            AddSubletView()
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("New Listing"))
                        ForEach(sublettingViewModel.listings, id: \.identity) { sublet in
                            NavigationLink {
                                SubletDetailView(sublet: sublet)
                            } label: {
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
                        NavigationLink(destination: NewListingForm()) {
                            AddSubletView()
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("New Listing"))
                        ForEach(sublettingViewModel.drafts, id: \.identity) { sublet in
                            NavigationLink {
                                // TODO: fill out
                            } label: {
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
                    VStack {
                        ForEach(sublettingViewModel.saved, id: \.identity) { sublet in
                            NavigationLink {
                                SubletDetailView(sublet: sublet)
                            } label: {
                                SubletDisplayRow(sublet: sublet)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .tag(SublettingViewModel.ListingsTabs.saved)
                
                // Applied tab
                ScrollView {
                    VStack {
                        ForEach(sublettingViewModel.applied, id: \.identity) { sublet in
                            NavigationLink {
                                SubletDetailView(sublet: sublet)
                            } label: {
                                SubletDisplayRow(sublet: sublet)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(.plain)
                        }
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
                    NavigationLink(destination: NewListingForm()) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(Text("New Listing"))
                }
            }
        }
        .alert(isPresented: $showLoginAlert) {
            Alert(title: Text("You must log in to access this feature."), message: Text("Please login on the \"More\" tab."), dismissButton: .default(Text("Ok"), action: { dismiss() }))
        }
    }
}

#Preview {
    MyListingsActivity(isListings: true)
}
