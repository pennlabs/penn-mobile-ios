//
//  SublettingView.swift
//  PennMobile
//
//  Created by Jordan H on 1/28/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

class MarketplaceView: ObservableObject {
}

struct SublettingView: View {
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    @State var sublets: [Sublet] = []
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Image(systemName: "bookmark")
                    SearchBar(searchText: $searchText)
                    Image(systemName: "slider.horizontal.3")
                }
                .padding()
                HStack {
                    Spacer()
                    Text("Sort by")
                    Text("Temp")
                }
            }
            .background(.white)
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(sublets) { sublet in
                        SubletItem(sublet: sublet)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
