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
    let isSubletterView: Bool
    let isDraft: Bool
    @State private var showMenu = false
    
    public init(sublet: Sublet, isSubletterView: Bool = false, isDraft: Bool = false) {
        self.sublet = sublet
        self.isSubletterView = isSubletterView
        self.isDraft = isDraft
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            KFImage(URL(string: sublet.images[0].imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(sublet.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if isSubletterView {
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
                
                Text("$\(sublet.price) (Negotiable)")
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
                
                Text("\(formatDate(sublet.startDate)) - \(formatDate(sublet.endDate))")
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
