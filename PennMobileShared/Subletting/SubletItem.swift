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
            
            Text("$\(sublet.price) (Negotiable)")
            
            if let beds = sublet.beds, let baths = sublet.baths {
                Text("\(beds) bd | \(String(format: "%.1f", baths)) ba")
                    .font(.subheadline)
            } else if let beds = sublet.beds {
                Text("\(beds) bd")
                    .font(.subheadline)
            } else if let baths = sublet.baths {
                Text("\(String(format: "%.1f", baths)) ba")
                    .font(.subheadline)
            }
            
            if let start = sublet.startDate.date, let end = sublet.endDate.date {
                Text("\(formatDate(start)) - \(formatDate(end))")
                    .font(.subheadline)
                    .italic()
            }
        }
        .padding()
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
