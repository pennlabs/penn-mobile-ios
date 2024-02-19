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
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    @EnvironmentObject private var sublettingViewModel: SublettingViewModel
    @State private var isListings: Bool
    @State private var selectedTab: SublettingViewModel.ListingsTabs
    
    init(isListings: Bool = false) {
        self.isListings = isListings
        self.selectedTab = isListings ? .posted : .saved
    }
    
    var body: some View {
        NavigationStack {
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
                        LazyVGrid(columns: columns) {
                            ForEach(sublettingViewModel.listings) { sublet in
                                NavigationLink {
                                    SubletDetailView(sublet: sublet, isSubletter: true)
                                } label: {
                                    SubletDisplayBox(sublet: sublet, isSubletter: true)
                                        .padding(5)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .tag(SublettingViewModel.ListingsTabs.posted)
                    
                    // Drafts tab
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(sublettingViewModel.drafts) { sublet in
                                NavigationLink {
                                    SubletDetailView(sublet: sublet, isSubletter: true)
                                } label: {
                                    SubletDisplayBox(sublet: sublet, isSubletter: true, isDraft: true)
                                        .padding(5)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .tag(SublettingViewModel.ListingsTabs.drafts)
                    
                    // Saved tab
                    ScrollView {
                        VStack {
                            ForEach(sublettingViewModel.saved) { sublet in
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
                            ForEach(sublettingViewModel.applied) { sublet in
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
        }
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
    }
}

#Preview {
    MyListingsActivity(isListings: true)
}
