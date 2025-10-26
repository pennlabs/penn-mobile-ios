//
//  LocationCell.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 3/2/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher

struct GSRLocationCell: View {
    let height: CGFloat = 100
    
    fileprivate var location: GSRLocation

    @State private var availabilityCount: Int? = nil
    
    init(location: GSRLocation) {
        self.location = location
    }
    
    var body: some View {
        HStack {
            KFImage(URL(string: location.imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 80)
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack (alignment: .leading, spacing: 6){
                Text(location.name)
                    .font(.system(size: 18))
                if let count = availabilityCount {
                    if (count == 0) {
                        HStack {
                            Image(systemName:"circle.fill")
                            Text("All reserved")
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.baseRed)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                        )
                    } else {
                        HStack {
                            Image(systemName:"circle.fill")
                            Text("\(count) open now")
                        }
                        .font(.system(size: 12))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .foregroundColor(.baseGreen)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                        )
                    }
                } else {
                    ProgressView()
                }
            }
            .padding(.leading, 16)
            Spacer()
            Image(systemName: "chevron.right")
                .bold()
        }
        .frame(height: height)
        .cornerRadius(8)
        .contentShape(.rect)
        .task {
            await loadAvailability()
        }
    }
    
    private func loadAvailability() async {
        do {
            let count = try await GSRAvailability.getGSRSCurrentlyOpen(location: location)
            availabilityCount = count
        } catch {
            availabilityCount = nil
        }
    }
}
