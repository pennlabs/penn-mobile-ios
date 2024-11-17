//
//  MyListingsActivity.swift
//  PennMobile
//
//  Created by Jordan H on 2/03/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import PennMobileShared
import SwiftUI

extension SublettingViewModel.ListingsTabs {
    var tabView: some View {
        Text(self.rawValue).tag(self)
    }
}

struct MyListingsActivity: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var sublettingViewModel: SublettingViewModel
    private var isListings: Bool
    private let initialTab: SublettingViewModel.ListingsTabs // I have no idea why I need to do this workaround with initialTab, but straight initializing the selectedTab to the proper value is not updating the UI (at least when arriving via modifying NavigationPath)
    @State private var selectedTab: SublettingViewModel.ListingsTabs
    @State private var showLoginAlert: Bool
    
    public init(isListings: Bool = false, initialTab: SublettingViewModel.ListingsTabs? = nil) {
        self.isListings = isListings
        var tab: SublettingViewModel.ListingsTabs = isListings ? .posted : .saved
        if let initialTab {
            if isListings && (initialTab == .posted || initialTab == .drafts) {
                tab = initialTab
            } else if !isListings && (initialTab == .saved || initialTab == .applied) {
                tab = initialTab
            }
        }
        self.initialTab = tab
        self._selectedTab = State(initialValue: tab)
        self._showLoginAlert = State(initialValue: !Account.isLoggedIn)
    }
    
    var body: some View {
        VStack {
            Picker("Tab", selection: $selectedTab.animation()) {
                if isListings {
                    SublettingViewModel.ListingsTabs.posted.tabView
                    SublettingViewModel.ListingsTabs.drafts.tabView
                } else {
                    SublettingViewModel.ListingsTabs.saved.tabView
                    SublettingViewModel.ListingsTabs.applied.tabView
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
                        
                        ForEach(sublettingViewModel.drafts) { subletDraft in
                            NavigationLink(value: SublettingPage.editSubletDraftForm(subletDraft)) {
                                SubletDisplayRow(subletDraft: subletDraft)
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
        .onAppear {
            selectedTab = initialTab
        }
    }
}

#Preview {
    MyListingsActivity(isListings: true)
}
