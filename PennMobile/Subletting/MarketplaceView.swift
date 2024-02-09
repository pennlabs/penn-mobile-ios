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
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Image(systemName: "bookmark")
                    SearchBar(searchText: $marketplaceViewModel.searchText)
                    Image(systemName: "slider.horizontal.3")
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
            .background(.white)
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(marketplaceViewModel.sublets) { sublet in
                        SubletItem(sublet: sublet)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    MarketplaceView()
}
