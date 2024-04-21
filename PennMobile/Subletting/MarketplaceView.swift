//
//  MarketplaceView.swift
//  PennMobile
//
//  Created by Jordan H on 1/28/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

// Codable since used in NavigationPath()
enum SublettingPage: Hashable, Identifiable, Equatable, Codable {
    case myListings(SublettingViewModel.ListingsTabs? = .posted)
    case myActivity(SublettingViewModel.ListingsTabs? = .saved)
    case subletDetailView(Int)
    case subletInterestForm(Sublet)
    case subletMapView(Sublet)
    case newListingForm
    case editSubletDraftForm(SubletDraft)
    case editSubletForm(Sublet)
    
    var id: SublettingPage { self }
    
    enum CodingKeys: CodingKey {
        case myListings, myActivity, subletDetailView, subletInterestForm, subletMapView, newListingForm, editSubletDraftForm, editSubletForm
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let tab = try? container.decode(SublettingViewModel.ListingsTabs.self, forKey: .myListings) {
            self = .myListings(tab)
        } else if let tab = try? container.decode(SublettingViewModel.ListingsTabs.self, forKey: .myActivity) {
            self = .myActivity(tab)
        } else if let id = try? container.decode(Int.self, forKey: .subletDetailView) {
            self = .subletDetailView(id)
        } else if let sublet = try? container.decode(Sublet.self, forKey: .subletInterestForm) {
            self = .subletInterestForm(sublet)
        } else if let sublet = try? container.decode(Sublet.self, forKey: .subletMapView) {
            self = .subletMapView(sublet)
        } else if let _ = try? container.decodeNil(forKey: .newListingForm) {
            self = .newListingForm
        } else if let subletDraft = try? container.decode(SubletDraft.self, forKey: .editSubletDraftForm) {
            self = .editSubletDraftForm(subletDraft)
        } else if let sublet = try? container.decode(Sublet.self, forKey: .editSubletForm) {
            self = .editSubletForm(sublet)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .myListings, in: container, debugDescription: "Unable to decode SublettingPage")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .myListings(let tab):
            try container.encode(tab, forKey: .myListings)
        case .myActivity(let tab):
            try container.encode(tab, forKey: .myActivity)
        case .subletDetailView(let id):
            try container.encode(id, forKey: .subletDetailView)
        case .subletInterestForm(let sublet):
            try container.encode(sublet, forKey: .subletInterestForm)
        case .subletMapView(let sublet):
            try container.encode(sublet, forKey: .subletMapView)
        case .newListingForm:
            try container.encodeNil(forKey: .newListingForm)
        case .editSubletDraftForm(let subletDraft):
            try container.encode(subletDraft, forKey: .editSubletDraftForm)
        case .editSubletForm(let sublet):
            try container.encode(sublet, forKey: .editSubletForm)
        }
    }
}

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
                
                Button("Pin to tab bar...") {
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
                        Text("No sublets found!")
                            .foregroundStyle(.tertiary)
                            .font(.subheadline)
                    }
                }
            }
            .refreshable {
                await sublettingViewModel.populateSublets()
                await sublettingViewModel.populateFiltered()
            }
        }
        .padding(.horizontal)
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
                SubletDetailView(subletID: subletID) // uses ID since needs to update when VM updates sublet while on the page
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
