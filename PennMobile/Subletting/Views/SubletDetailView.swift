//
//  SubletDetailView.swift
//  PennMobileShared
//
//  Created by Jordan H on 2/17/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher

struct SubletDetailView: View {
    @EnvironmentObject var sublettingViewModel: SublettingViewModel
    var subletID: Int?
    var sublet: Sublet {
        subletID != nil ? (sublettingViewModel.getSublet(subletID: subletID!) ?? Sublet.mock) : Sublet.mock
    }
    @State var selectedTab = "Details"
    @State var showExternalLink = false
    var isSaved: Bool {
        sublettingViewModel.isFavorited(sublet: sublet)
    }
    var isSubletter: Bool {
        Account.getAccount()?.pennid == sublet.subletter
    }
    var isClaimed: Bool = false // TODO: add claimed later
    
    public init(subletID: Int? = nil) {
        self.subletID = subletID
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
                        .padding([.horizontal, .top])
                        
                        // TabView does not like displaying content when inside ScrollView
                        if selectedTab == "Details" {
                            SubletDetailOnly(sublet: sublet)
                                .transition(.move(edge: .leading))
                        } else {
                            SubletCandidatesView(sublet: sublet)
                                .transition(.move(edge: .trailing))
                        }
                    }
                    .frame(minHeight: proxy.size.height)
                    .clipped()
                    .contentShape(.rect)
                    .simultaneousGesture(
                        DragGesture()
                            .onEnded { value in
                                if abs(value.translation.width) > abs(value.translation.height) {
                                    if value.translation.width < 0 {
                                        withAnimation {
                                            selectedTab = "Candidates"
                                        }
                                    } else if value.translation.width > 0 {
                                        withAnimation {
                                            selectedTab = "Details"
                                        }
                                    }
                                }
                            }
                    )
                } else {
                    SubletDetailOnly(sublet: sublet)
                }
            }
            .refreshable {
                if let sublet = try? await SublettingAPI.instance.getSubletDetails(id: sublet.subletID, withOffers: isSubletter) {
                    sublettingViewModel.updateSublet(sublet: sublet)
                }
            }
        }
        .navigationTitle(selectedTab)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                SubletDetailToolbar(sublet: sublet, showExternalLink: $showExternalLink)
            }
        }
        .task {
            if let sublet = try? await SublettingAPI.instance.getSubletDetails(id: sublet.subletID, withOffers: isSubletter) {
                sublettingViewModel.updateSublet(sublet: sublet)
            }
        }
        .safari(isPresented: $showExternalLink, url: sublet.data.externalLink.flatMap { URL(string: $0) })
    }
}

struct SubletDetailOnly: View {
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    @EnvironmentObject var sublettingViewModel: SublettingViewModel
    @State private var currentIndex = 0
    var sublet: Sublet
    var isSaved: Bool {
        sublettingViewModel.isFavorited(sublet: sublet)
    }
    var isSubletter: Bool {
        Account.getAccount()?.pennid == sublet.subletter
    }
    var isClaimed: Bool = false // TODO: add claimed later
    
    public init(sublet: Sublet) {
        self.sublet = sublet
    }
        
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TabView(selection: $currentIndex) {
                ForEach(sublet.images.indices, id: \.self) { index in
                    KFImage(URL(string: sublet.images[index].imageUrl))
                        .placeholder {
                            ProgressView()
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 300)
            
            if sublet.images.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<sublet.images.count, id: \.self) { index in
                        Circle()
                            .fill(currentIndex == index ? Color.baseLabsBlue : .secondary)
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text(sublet.title)
                        .font(.headline)
                    
                    if isSubletter {
                        Spacer()
                        
                        NavigationLink(value: SublettingPage.editSubletForm(sublet)) {
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
                    Text("\(beds) bd | \(String.customFormat(minFractionDigits: 0, maxFractionDigits: 1, baths)) ba")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else if let beds = sublet.beds {
                    Text("\(beds) bd")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else if let baths = sublet.baths {
                    Text("\(String.customFormat(minFractionDigits: 0, maxFractionDigits: 1, baths)) ba")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let address = sublet.address, !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    HStack {
                        Text(address)
                            .font(.subheadline)
                        
                        NavigationLink(value: SublettingPage.subletMapView(sublet)) {
                            HStack(spacing: 4) {
                                Image(systemName: "map")
                                Text("view in map")
                            }
                            .font(.caption)
                        }
                        
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
                } else if Account.isLoggedIn {
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
                        .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5), value: isSaved)
                        .padding(.top, 10)
                        
                        NavigationLink(value: SublettingPage.subletInterestForm(sublet)) {
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
            
            if let description = sublet.description, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Divider()
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.subheadline)
                        .bold()
                    Text(description)
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
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            if let expiresAt = sublet.expiresAt {
                Divider()
                VStack(alignment: .leading) {
                    Text("Listing Expires on")
                        .font(.subheadline)
                        .bold()
                    Text("\(formatDate(expiresAt))")
                        .font(.subheadline)
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

struct SubletDetailToolbar: View {
    @EnvironmentObject var sublettingViewModel: SublettingViewModel
    let sublet: Sublet
    @Binding var showExternalLink: Bool
    var isSaved: Bool {
        sublettingViewModel.isFavorited(sublet: sublet)
    }
    var isSubletter: Bool {
        Account.getAccount()?.pennid == sublet.subletter
    }
    
    var body: some View {
        HStack {
            if !isSubletter && Account.isLoggedIn {
                NavigationLink(value: SublettingPage.subletInterestForm(sublet)) {
                    Image(systemName: "ellipsis.message")
                }
                
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
                .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5), value: isSaved)
            }
            
            if let link = sublet.data.externalLink, let _ = URL(string: link) {
                Button(action: {
                    showExternalLink = true
                }) {
                    Image(systemName: "link")
                }
            }
        }
    }
}

#Preview {
    SubletDetailView()
}
