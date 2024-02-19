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

public struct SubletDisplayBox: View {
    let sublet: Sublet
    let isSubletter: Bool
    let isDraft: Bool
    
    public init(sublet: Sublet, isSubletter: Bool = false, isDraft: Bool = false) {
        self.sublet = sublet
        self.isSubletter = isSubletter
        self.isDraft = isDraft
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            KFImage(URL(string: sublet.images.count > 0 ? sublet.images[0].imageUrl : ""))
                .placeholder {
                    Color.gray
                        .aspectRatio(contentMode: .fill)
                }
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(sublet.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if isSubletter {
                        Menu {
                            Button("Edit", action: {
                                // Handle edit action
                            })
                            if isDraft {
                                Button("Remove", action: {
                                    // Handle mark as claimed action
                                })
                            } else {
                                Button("Mark as claimed", action: {
                                    // Handle mark as claimed action
                                })
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                
                Text("$\(sublet.price)\(sublet.negotiable ? " (Negotiable)" : "")")
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
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
