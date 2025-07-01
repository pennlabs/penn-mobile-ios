//
//  SubletDisplayRow.swift
//  PennMobile
//
//  Created by Jordan H on 2/18/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher

struct SubletDisplayRow: View {
    let sublet: Sublet
    let images: [UIImage]?
    let isApplied: Bool
    var isSubletter: Bool {
        Account.getAccount()?.pennid == sublet.subletter
    }
    @State var messageExpanded: Bool = false
    
    public init(sublet: Sublet, isApplied: Bool = false) {
        self.sublet = sublet
        self.images = nil
        self.isApplied = isApplied
    }
    
    public init(subletDraft: SubletDraft) {
        var sublet = Sublet.mock
        sublet.data = subletDraft.data
        sublet.subletter = -1
        self.sublet = sublet
        self.images = subletDraft.images
        self.isApplied = false
    }
    
    public var body: some View {
        HStack {
            if let images {
                if images.count > 0 {
                    Image(uiImage: images[0])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .frame(width: 150)
                } else {
                    Color.gray
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .frame(width: 150)
                }
            } else {
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
                    .frame(width: 150)
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text(sublet.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if isSubletter && sublet.offers?.count ?? 0 > 0 {
                        ZStack {
                            Circle()
                                .fill(.red)
                                .frame(width: 15, height: 15)
                            
                            Text("\(sublet.offers?.count ?? 0)")
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                        }
                    }
                }
                
                Text("$\(sublet.price)\(sublet.negotiable ? " (Negotiable)" : "")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
                
                if isApplied {
                    VStack {
                        if messageExpanded {
                            Text("Submitted: ...")
                        }
                        Button(action: {
                            messageExpanded.toggle()
                        }) {
                            Text(messageExpanded ? "Hide Message" : "View Message")
                                .font(.subheadline)
                                .bold()
                                .background(Color.baseLabsBlue)
                        }
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

struct AddSubletView: View {
    var body: some View {
        VStack {
            Image(systemName: "plus")
            Text("Add listing")
        }
        .foregroundColor(.secondary)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.clear)
        .contentShape(Rectangle())
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [7]))
                .foregroundColor(.secondary)
        )
        .frame(height: 120)
    }
}

#Preview {
    SubletDisplayRow(sublet: Sublet.mock)
}
