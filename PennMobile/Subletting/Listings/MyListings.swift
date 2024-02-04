//
//  MyListings.swift
//  PennMobile
//
//  Created by Jordan H on 2/03/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import PennMobileShared
import SwiftUI

class ListingsViewModel: ObservableObject {
    var listings: [Sublet]
    var drafts: [Sublet]
    
    @Published var tab: Tab = .posted
    
    enum Tab: CaseIterable {
        case posted
        case drafts
    }
    
    init(listings: [Sublet], drafts: [Sublet]) {
        self.listings = listings
        self.drafts = drafts
    }
    
    init() {
        self.drafts = UserDefaults.standard.array(forKey: "drafts") as? [Sublet] ?? []
        
        self.listings = []
        
        Task {
            self.listings = try await SublettingAPI.instance.getSublets(queryParameters: ["subletter": "true"])
        }
    }
}

struct MyListings: View {
    @ObservedObject private var viewModel: ListingsViewModel
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    init(viewModel: ListingsViewModel) {
        self.viewModel = viewModel
    }
    
    init() {
        self.viewModel = ListingsViewModel()
    }
    
    var body: some View {
        VStack {
            Picker("Tab", selection: $viewModel.tab.animation()) {
                Text("Posted").tag(ListingsViewModel.Tab.posted)
                Text("Drafts").tag(ListingsViewModel.Tab.drafts)
            }
            .pickerStyle(.segmented)
            .padding()
            
            TabView(selection: $viewModel.tab) {
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(viewModel.listings) { sublet in
                            SubletItem(sublet: sublet)
                        }
                    }
                }
                    .tag(ListingsViewModel.Tab.posted)
                Text("Tab Content 2").tabItem { Text("Tab Label 2") }
                    .tag(ListingsViewModel.Tab.drafts)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .navigationTitle("My Listings")
        }
        .toolbar {
            ToolbarItem {
                NavigationLink(destination: NewListingForm()) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(Text("New Listing"))
            }
        }
    }
}

#Preview {
    MyListings(viewModel: .init(listings: [.mock], drafts: [.mock]))
}
