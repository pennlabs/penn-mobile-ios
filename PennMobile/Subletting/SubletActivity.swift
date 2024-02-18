//
//  SubletActivity.swift
//  PennMobile
//
//  Created by Jordan H on 2/18/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import PennMobileShared
import SwiftUI

// Note that this is basically identical to MyListings, so maybe we want to combine them
struct SubletActivity: View {
    @ObservedObject var marketplaceViewModel: MarketplaceViewModel
    @State var selectedTab: String = "Saved"
    @State private var saved: [Sublet] = []
    @State private var applied: [Sublet] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Tab", selection: $selectedTab.animation()) {
                    Text("Saved").tag("Saved")
                    Text("Applied").tag("Applied")
                }
                .pickerStyle(.segmented)
                .padding()
                
                TabView(selection: $selectedTab) {
                    // Saved tab
                    ScrollView {
                        VStack {
                            ForEach(saved) { sublet in
                                SubletActivityRow(sublet: sublet, marketplaceViewModel: marketplaceViewModel)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .tag("Saved")
                    
                    // Applied tab
                    ScrollView {
                        VStack {
                            ForEach(applied) { sublet in
                                SubletActivityRow(sublet: sublet, marketplaceViewModel: marketplaceViewModel)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .tag("Applied")
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .navigationTitle("My Activity")
        }
        .task {
            Task {
                saved = await marketplaceViewModel.getFavorites()
            }
            Task {
                applied = []
            }
        }
    }
}

#Preview {
    SubletActivity(marketplaceViewModel: MarketplaceViewModel())
}
