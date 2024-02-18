//
//  SubletDisplayRow.swift
//  PennMobile
//
//  Created by Jordan H on 2/18/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher
import PennMobileShared

struct SubletDisplayRow: View {
    let sublet: Sublet
    let isApplied: Bool = false
    @State var messageExpanded: Bool = false
    
    public var body: some View {
        NavigationLink {
            SubletDetailView(sublet: sublet)
        } label: {
            HStack {
                KFImage(URL(string: sublet.images.count > 0 ? sublet.images[0].imageUrl : ""))
                    .placeholder {
                        Color.gray
                            .aspectRatio(contentMode: .fill)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .frame(maxWidth: 120)
                
                VStack(alignment: .leading) {
                    HStack {
                        Circle()
                            .foregroundColor(.green)
                            .frame(width: 10, height: 10)
                        Text("OPEN")
                            .fontWeight(.medium)
                    }
                    
                    Text(sublet.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text("$\(sublet.price)\(sublet.negotiable ? " (Negotiable)" : "")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
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
                    
                    if isApplied {
                        VStack {
                            if messageExpanded {
                                Text("Submitted: ...")
                            }
                            Button(action: {
                                messageExpanded.toggle()
                            }) {
                                Text(messageExpanded ? "Hide Message" : "View Message")
                                    .background(Color.baseLabsBlue)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
            }
        }
        .buttonStyle(.plain)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

#Preview {
    SubletDisplayRow(sublet: Sublet.mock)
}
