//
//  MarketplaceView.swift
//  PennMobile
//
//  Created by Jordan H on 1/28/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct SublettingTabHint: View {
    @AppStorage("sublettingTabHintWasDismissed") var tabHintDismissed = false
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        if tabHintDismissed {
            AnyView(SwiftUI.EmptyView())
        } else {
            AnyView(HStack {
                Text("Want quick access to sublets?")
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Pin to tab bar") {
                    var currentTabFeatures = UserDefaults.standard.getTabPreferences()
                    
                    tabHintDismissed = true
                    
                    if !currentTabFeatures.contains(.subletting) {
                        currentTabFeatures[3] = .subletting
                        UserDefaults.standard.setTabPreferences(currentTabFeatures)
                        navigationManager.resetPath()
                        navigationManager.currentTab = FeatureIdentifier.subletting.rawValue
                    }
                }
                .buttonStyle(BorderedButtonStyle())
                .buttonBorderShape(.capsule)
                
                Button {
                    tabHintDismissed = true
                } label: {
                    Label("Dismiss", systemImage: "xmark.circle.fill")
                        .labelStyle(.iconOnly)
                }
            }
            .tint(.primary)
            .padding()
            .environment(\.colorScheme, .dark)
            .background(HomeSublettingBanner.gradient)
            .clipShape(.rect(cornerRadius: 16))
            .onAppear {
                if UserDefaults.standard.getTabPreferences().contains(.subletting) {
                    tabHintDismissed = true
                }
            })
        }
    }
}

struct MarketplaceView: View {
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    @StateObject private var sublettingViewModel = SublettingViewModel()
    @State private var showingFilters = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    NavigationLink(value: SublettingPage.myActivity()) {
                        Image(systemName: "bookmark")
                    }
                    .buttonStyle(.plain)
                    
                    SearchBar(searchText: $sublettingViewModel.searchText)
                    
                    Button(action: {
                        showingFilters.toggle()
                    }) {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showingFilters) {
                        MarketplaceFilterView(sublettingViewModel: sublettingViewModel)
                    }
                }
                .padding()
                HStack {
                    Spacer()
                    Text("Sort by")
                    Picker(selection: $sublettingViewModel.sortOption, label: Text(sublettingViewModel.sortOption)) {
                        ForEach(sublettingViewModel.sortOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.primary, lineWidth: 1)
                    )
                }
            }
            .background(Color.uiBackground)
            ScrollView {
                VStack(spacing: 16) {
                    VStack {
                        Text("Penn Mobile Sublet is currently in beta. Have feedback? We're happy to hear it!")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        Link("Share Feedback...", destination: feedbackURL)
                            .fontWeight(.medium)
                    }
                    .padding(.top, 4)
                    .font(.callout)
                    
                    SublettingTabHint()
                    
                    if sublettingViewModel.sortedFilteredSublets.count > 0 {
                        LazyVGrid(columns: columns) {
                            ForEach(sublettingViewModel.sortedFilteredSublets) { sublet in
                                NavigationLink(value: SublettingPage.subletDetailView(sublet.subletID)) {
                                    SubletDisplayBox(sublet: sublet)
                                }
                                .buttonStyle(.plain)
                                .padding(5)
                            }
                        }
                    } else {
                        Text(Account.isLoggedIn ? "No sublets found!" : "You must login to view sublets!")
                            .foregroundStyle(.tertiary)
                            .font(.subheadline)
                    }
                }
            }
            .padding(.horizontal)
            .refreshable {
                await sublettingViewModel.populateSublets()
                await sublettingViewModel.populateFiltered()
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .toolbar {
            ToolbarItem {
                NavigationLink(value: SublettingPage.myListings()) {
                    Text("My Listings")
                }
            }
        }
        .navigationDestination(for: SublettingPage.self) { page in
            switch page {
            case .myListings(let tab):
                MyListingsActivity(isListings: true, initialTab: tab)
                    .environmentObject(sublettingViewModel)
            case .myActivity(let tab):
                MyListingsActivity(isListings: false, initialTab: tab)
                    .environmentObject(sublettingViewModel)
            case .subletDetailView(let subletID):
                SubletDetailView(subletID: subletID)
                    .environmentObject(sublettingViewModel)
            case .subletInterestForm(let sublet):
                SubletInterestForm(sublet: sublet)
                    .environmentObject(sublettingViewModel)
            case .subletMapView(let sublet):
                SubletMapView(sublet: sublet)
                    .environmentObject(sublettingViewModel)
            case .newListingForm:
                NewListingForm()
                    .environmentObject(sublettingViewModel)
            case .editSubletDraftForm(let subletDraft):
                NewListingForm(subletDraft: subletDraft)
                    .environmentObject(sublettingViewModel)
            case .editSubletForm(let sublet):
                NewListingForm(sublet: sublet)
                    .environmentObject(sublettingViewModel)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MarketplaceView()
}
