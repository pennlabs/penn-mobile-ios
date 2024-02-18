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
                        VStack {
                            ForEach(sublettingViewModel.listings) { sublet in
                                SubletDisplayRow(sublet: sublet)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .tag(SublettingViewModel.ListingsTabs.posted)
                    
                    // Drafts tab
                    ScrollView {
                        VStack {
                            ForEach(sublettingViewModel.drafts) { sublet in
                                SubletDisplayRow(sublet: sublet)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .tag(SublettingViewModel.ListingsTabs.drafts)
                    
                    // Saved tab
                    ScrollView {
                        VStack {
                            ForEach(sublettingViewModel.saved) { sublet in
                                SubletDisplayRow(sublet: sublet)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .tag(SublettingViewModel.ListingsTabs.saved)
                    
                    // Applied tab
                    ScrollView {
                        VStack {
                            ForEach(sublettingViewModel.applied) { sublet in
                                SubletDisplayRow(sublet: sublet)
                                    .padding(.horizontal)
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
