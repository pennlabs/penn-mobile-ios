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
    @State var showExternalLink = false
    @State var sublet: Sublet
    @State var selectedTab = "Details"
    @EnvironmentObject var sublettingViewModel: SublettingViewModel
    private var isSaved: Bool {
        sublettingViewModel.isFavorited(sublet: sublet)
    }
    var isSubletter: Bool {
        Account.getAccount()?.pennid == sublet.subletter
    }
    private var isClaimed: Bool = false // TODO: add claimed later
    
    public init(sublet: Sublet) {
        self._sublet = State(initialValue: sublet)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                if isSubletter {
                    VStack {
                        Picker("Tab", selection: $selectedTab.animation()) {
                            Text("Details").tag("Details")
                            Text("Candidates").tag("Candidates")
                        }
                        .pickerStyle(.segmented)
                        .customBadge("\(sublet.offers?.count ?? 0)", enabled: sublet.offers?.count ?? 0 > 0)
                        .padding(.horizontal)
                        
                        TabView(selection: $selectedTab) {
                            SubletDetailOnly(sublet: sublet, isSubletter: isSubletter)
                                .tag("Details")
                            
                            SubletCandidatesView(sublet: sublet)
                                .tag("Candidates")
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(minHeight: proxy.size.height)
                    }
                } else {
                    SubletDetailOnly(sublet: sublet, isSubletter: isSubletter)
                }
            }
        }
        .navigationTitle(selectedTab)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if selectedTab == "Details" {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        if !isSubletter {
                            NavigationLink {
                                SubletInterestForm(sublet: sublet)
                            } label: {
                                Image(systemName: "ellipsis.message")
                            }
                            .buttonStyle(.plain)
                            Button(action: {
                                Task {
                                    if isSaved {
                                        await sublettingViewModel.unfavoriteSublet(sublet: sublet)
                                    } else {
                                        await sublettingViewModel.favoriteSublet(sublet: sublet)
                                    }
                                }
                            }) {
                                Image(systemName: isSaved ? "heart.fill" : "heart")
                            }
                            .buttonStyle(.plain)
                        }
                        if sublet.data.externalLink != nil {
                            Button(action: {
                                showExternalLink = true
                            }) {
                                Image(systemName: "link")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .task {
            if let sublet = try? await SublettingAPI.instance.getSubletDetails(id: sublet.id, withOffers: isSubletter) {
                self.sublet = sublet
                sublettingViewModel.updateSublet(sublet: sublet)
            }
        }
        .sheet(isPresented: $showExternalLink) {
            WebView(url: URL(string: sublet.data.externalLink!)!)
        }
    }
}

struct SubletDetailOnly: View {
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    @State var sublet: Sublet
    @EnvironmentObject var sublettingViewModel: SublettingViewModel
    private var isSaved: Bool {
        sublettingViewModel.isFavorited(sublet: sublet)
    }
    let isSubletter: Bool
    private var isClaimed: Bool = false // TODO: add claimed later
    
    public init(sublet: Sublet) {
        self._sublet = State(initialValue: sublet)
        self.isSubletter = false
    }
    
    public init(sublet: Sublet, isSubletter: Bool) {
        self._sublet = State(initialValue: sublet)
        self.isSubletter = isSubletter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            KFImage(URL(string: sublet.images.count > 0 ? sublet.images[0].imageUrl : ""))
                .placeholder {
                    Color.gray
                        .aspectRatio(contentMode: .fit)
                }
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(sublet.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if isSubletter {
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
                
                if isSubletter {
//                    Button(action: {}) {
//                        if isClaimed {
//                            Button(action: {}) {
//                                Text("Mark as available")
//                                    .font(.title3)
//                                    .bold()
//                                    .foregroundColor(Color.white)
//                                    .padding(.vertical, 10)
//                                    .frame(maxWidth: .infinity, alignment: .center)
//                                    .background(
//                                        Capsule()
//                                            .fill(Color.blueLighter)
//                                    )
//                            }
//                            .padding(.top, 10)
//                        } else {
//                            Button(action: {}) {
//                                Text("Mark as claimed")
//                                    .font(.title3)
//                                    .bold()
//                                    .foregroundColor(Color.white)
//                                    .padding(.vertical, 10)
//                                    .frame(maxWidth: .infinity, alignment: .center)
//                                    .background(
//                                        Capsule()
//                                            .fill(Color.baseLabsBlue)
//                                    )
//                            }
//                            .padding(.top, 10)
//                        }
//                    }
                } else {
                    HStack {
                        Button(action: {
                            Task {
                                if isSaved {
                                    await sublettingViewModel.unfavoriteSublet(sublet: sublet)
                                } else {
                                    await sublettingViewModel.favoriteSublet(sublet: sublet)
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
                        
                        NavigationLink {
                            SubletInterestForm(sublet: sublet)
                        } label: {
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
                        .buttonStyle(.plain)
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
                                Text(amenity)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    SubletDetailView(sublet: Sublet.mock)
}
