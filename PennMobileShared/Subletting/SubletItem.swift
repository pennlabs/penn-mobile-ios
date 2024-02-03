//
//  SubletItem.swift
//  PennMobileShared
//
//  Created by George Botros on 2/3/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI
import Kingfisher

public struct SubletItem: View {
    let sublet: Sublet
    
    public init(sublet: Sublet) {
        self.sublet = sublet
    }
    
    public var body: some View {
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
