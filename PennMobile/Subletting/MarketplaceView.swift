//
//  MarketplaceView.swift
//  PennMobile
//
//  Created by Jordan H on 1/28/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

enum SublettingPage: Hashable, Identifiable {
    case myListings
    case myActivity
    case subletDetailView(Int)
    case subletInterestForm(Sublet)
    case subletMapView(Sublet)
    case newListingForm
    case editSubletDraftForm(SubletDraft)
    case editSubletForm(Sublet)
    
    var id: SublettingPage { self }
}

struct MarketplaceView: View {
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    @StateObject private var sublettingViewModel = SublettingViewModel()
    @State private var showingFilters = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    NavigationLink(value: SublettingPage.myActivity) {
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
        .padding(.horizontal)
        .toolbar {
            ToolbarItem {
                NavigationLink(value: SublettingPage.myListings) {
                    Text("My Listings")
                }
            }
        }
        .navigationDestination(for: SublettingPage.self) { page in
            switch page {
            case .myListings:
                MyListingsActivity(isListings: true)
                    .environmentObject(sublettingViewModel)
            case .myActivity:
                MyListingsActivity(isListings: false)
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
    }
}

#Preview {
    MarketplaceView()
}
