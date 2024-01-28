//
//  SublettingView.swift
//  PennMobile
//
//  Created by Jordan H on 1/28/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

class MarketplaceView: ObservableObject {
}

struct SublettingView: View {
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Image(systemName: "bookmark")
                    Text("Temp")
                    Image(systemName: "slider.horizontal.3")
                }
                HStack {
                    Spacer()
                    Text("Sort by")
                    Text("Temp")
                }
            }
            .background(.white)
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(0..<5) { index in
                        SubletItem()
                    }
                }
            }
        }
        .padding([.leading, .trailing])
    }
}

struct SubletItem: View {
    var body: some View {
        VStack(alignment: .leading) {
            Image("Image")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
            
            Text("The Speakeasy")
                .font(.headline)
            
            Text("$1200 (negotiable)")
            
            Text("2 bd | 2.5 ba")
                .font(.subheadline)
            
            Text("Jun 7 - Aug 28")
                .font(.subheadline)
                .italic()
        }
        .padding()
        .border(.black)
    }
}
