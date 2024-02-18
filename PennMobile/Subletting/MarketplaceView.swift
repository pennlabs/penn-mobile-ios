//
//  MarketplaceView.swift
//  PennMobile
//
//  Created by Jordan H on 1/28/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct MarketplaceView: View {
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    @StateObject private var sublettingViewModel = SublettingViewModel()
    @State private var showingFilters = false
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    HStack {
                        NavigationLink {
                            MyListingsActivity(isListings: false)
                        } label: {
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
                    LazyVGrid(columns: columns) {
                        ForEach(sublettingViewModel.sublets) { sublet in
                            NavigationLink {
                                SubletDetailView(sublet: sublet)
                            } label: {
                                SubletDisplayBox(sublet: sublet)
                            }
                            .buttonStyle(.plain)
                            .padding(5)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .toolbar {
            ToolbarItem {
                NavigationLink("My Listings") {
                    MyListingsActivity(isListings: true)
                }
            }
        }
        .environmentObject(sublettingViewModel)
        .task {
            await sublettingViewModel.populateSublets()
        }
    }
}

#Preview {
    MarketplaceView()
}
