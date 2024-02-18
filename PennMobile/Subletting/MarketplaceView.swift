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
    @StateObject private var marketplaceViewModel = MarketplaceViewModel()
    @State private var showingFilters = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    NavigationLink {
                        SubletActivity(marketplaceViewModel: marketplaceViewModel)
                    } label: {
                        Image(systemName: "bookmark")
                    }
                    .buttonStyle(.plain)
                    
                    SearchBar(searchText: $marketplaceViewModel.searchText)
                    
                    Button(action: {
                        showingFilters.toggle()
                    }) {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showingFilters) {
                        MarketplaceFilterView(marketplaceViewModel: marketplaceViewModel)
                    }
                }
                .padding()
                HStack {
                    Spacer()
                    Text("Sort by")
                    Picker(selection: $marketplaceViewModel.sortOption, label: Text(marketplaceViewModel.sortOption)) {
                        ForEach(marketplaceViewModel.sortOptions, id: \.self) { option in
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
                    ForEach(marketplaceViewModel.sublets) { sublet in
                        NavigationLink {
                            SubletDetailView(sublet: sublet, marketplaceViewModel: marketplaceViewModel)
                        } label: {
                            SubletItem(sublet: sublet)
                        }
                        .buttonStyle(.plain)
                        .padding(5)
                    }
                }
            }
        }
        .padding(.horizontal)
        .toolbar {
            ToolbarItem {
                NavigationLink("My Listings") {
                    MyListings()
                }
            }
        }
        .task {
            await marketplaceViewModel.populate()
        }
    }
}

#Preview {
    MarketplaceView()
}
