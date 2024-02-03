//
//  SublettingView.swift
//  PennMobile
//
//  Created by Jordan H on 1/28/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher
import PennMobileShared

class MarketplaceView: ObservableObject {
}

struct SublettingView: View {
    @State var sublets: [Sublet] = []
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
                    ForEach(sublets) { sublet in
                        SubletItem(sublet: sublet)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct SubletItem: View {
    let sublet: Sublet
    
    var body: some View {
        VStack(alignment: .leading) {
            KFImage(URL(string: sublet.images[0].imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
            
            Text(sublet.title)
                .font(.headline)
            
            Text("\(sublet.price) (Negotiable)")
            
            if let beds = sublet.beds, let baths = sublet.baths {
                Text("\(beds) bd | \(baths) ba")
                    .font(.subheadline)
            } else if let beds = sublet.beds {
                Text("\(beds) bd")
                    .font(.subheadline)
            } else if let baths = sublet.baths {
                Text("\(baths) ba")
                    .font(.subheadline)
            }
            
            Text("\(formatDate(sublet.startDate)) - \(formatDate(sublet.endDate))")
                .font(.subheadline)
                .italic()
        }
        .padding()
        .border(.black)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
