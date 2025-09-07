//
//  SubletDisplayBox.swift
//  PennMobileShared
//
//  Created by George Botros on 2/3/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI
import Kingfisher

struct SubletDisplayBox: View {
    let sublet: Sublet
    
    init(sublet: Sublet) {
        self.sublet = sublet
    }
    
    var body: some View {
        VStack {
            KFImage(URL(string: sublet.images.count > 0 ? sublet.images[0].imageUrl : ""))
                .placeholder {
                    if sublet.images.count > 0 {
                        ProgressView()
                    } else {
                        Color.gray
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .frame(height: 150)
            
            VStack(alignment: .leading) {
                Text(sublet.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("$\(sublet.price)\(sublet.negotiable ? " (Negotiable)" : "")")
                    .lineLimit(1)
                
                if let beds = sublet.beds, let baths = sublet.baths {
                    Text("\(beds) bd | \(String.customFormat(minFractionDigits: 0, maxFractionDigits: 1, baths)) ba")
                        .font(.subheadline)
                } else if let beds = sublet.beds {
                    Text("\(beds) bd")
                        .font(.subheadline)
                } else if let baths = sublet.baths {
                    Text("\(String.customFormat(minFractionDigits: 0, maxFractionDigits: 1, baths)) ba")
                        .font(.subheadline)
                }
                
                if let start = sublet.startDate.date, let end = sublet.endDate.date {
                    Text("\(formatDate(start)) - \(formatDate(end))")
                        .font(.subheadline)
                        .italic()
                }
            }
        }
        .contentShape(Rectangle())
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
