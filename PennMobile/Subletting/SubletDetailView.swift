//
//  SubletDetailView.swift
//  PennMobileShared
//
//  Created by Jordan H on 2/17/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher
import PennMobileShared

struct SubletDetailView: View {
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    @State var sublet: Sublet
    @ObservedObject var marketplaceViewModel: MarketplaceViewModel
    let isSubletterView: Bool
    private var isSaved: Bool {
        marketplaceViewModel.isFavorited(sublet: sublet)
    }
    private var isClaimed: Bool {
        // TODO
        false
    }

    init(sublet: Sublet, marketplaceViewModel: MarketplaceViewModel, isSubletterView: Bool = true) {
        self._sublet = State(initialValue: sublet)
        self.marketplaceViewModel = marketplaceViewModel
        self.isSubletterView = isSubletterView
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
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
                        
                        if isSubletterView {
                            Spacer()
                            
                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Image(systemName: "pencil.line")
                                    Text("Edit")
                                }
                            }
                        }
                    }
                    
                    Text("$\(sublet.price)\(sublet.negotiable ? " (Negotiable)" : "")")
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let beds = sublet.beds, let baths = sublet.baths {
                        Text("\(beds) bd | \(String(format: "%.1f", baths)) ba")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else if let beds = sublet.beds {
                        Text("\(beds) bd")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else if let baths = sublet.baths {
                        Text("\(String(format: "%.1f", baths)) ba")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if sublet.address != nil {
                        HStack {
                            Text(sublet.address!)
                                .font(.subheadline)
                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Image(systemName: "map")
                                    Text("view in map")
                                }
                            }
                            .font(.caption)
                            Spacer()
                        }
                    }
                    if isSubletterView {
                        Button(action: {
                            Task {
                                if isClaimed {
                                    await marketplaceViewModel.unfavoriteSublet(sublet: sublet)
                                } else {
                                    await marketplaceViewModel.favoriteSublet(sublet: sublet)
                                }
                            }
                        }) {
                            if isClaimed {
                                Button(action: {}) {
                                    Text("Mark as available")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(Color.white)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .background(
                                            Capsule()
                                                .fill(Color.blueLighter)
                                        )
                                }
                                .padding(.top, 10)
                            } else {
                                Button(action: {}) {
                                    Text("Mark as claimed")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(Color.white)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .background(
                                            Capsule()
                                                .fill(Color.baseLabsBlue)
                                        )
                                }
                                .padding(.top, 10)
                            }
                        }
                    } else {
                        HStack {
                            Button(action: {
                                Task {
                                    if isSaved {
                                        await marketplaceViewModel.unfavoriteSublet(sublet: sublet)
                                    } else {
                                        await marketplaceViewModel.favoriteSublet(sublet: sublet)
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: isSaved ? "heart.fill" : "heart")
                                    Text(isSaved ? "Unsave" : "Save")
                                        .font(.title3)
                                        .bold()
                                }
                                .foregroundColor(.primary)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(
                                    Capsule()
                                        .fill(Color.uiCardBackground)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.primary, lineWidth: 2)
                                )
                            }
                            .padding(.top, 10)
                            
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "ellipsis.message")
                                    Text("Interested")
                                        .font(.title3)
                                        .bold()
                                }
                                .foregroundColor(Color.white)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(
                                    Capsule()
                                        .fill(Color.baseLabsBlue)
                                )
                            }
                            .padding(.top, 10)
                        }
                    }
                }
                .padding(.horizontal)
                
                if let start = sublet.startDate.date, let end = sublet.endDate.date {
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Availability")
                            .font(.subheadline)
                            .bold()
                        Text("\(formatDate(start)) - \(formatDate(end))")
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                }
                
                if sublet.description != nil {
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.subheadline)
                            .bold()
                        Text(sublet.description!)
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                }
                
                if !sublet.amenities.isEmpty {
                    Divider()
                    VStack(alignment: .leading) {
                        Text("What this place offers")
                            .font(.subheadline)
                            .bold()
                        LazyVGrid(columns: columns) {
                            ForEach(sublet.amenities, id: \.self) { amenity in
                                HStack {
                                    Image(systemName: "checkmark.seal")
                                    Text(amenity.name)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    SubletDetailView(sublet: Sublet.mock, marketplaceViewModel: MarketplaceViewModel())
}
