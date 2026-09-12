//
//  GSRLocationListView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 10/3/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct GSRLocationListView: View {
    let locations: [GSRLocation]
    let openRoomCounts: [Int: Int]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                if locations.isEmpty {
                    ProgressView()
                        .padding()
                } else {
                    ForEach(Array(locations.enumerated()), id: \.element) { index, location in
                        if index > 0 {
                            Divider()
                        }
                        NavigationLink(value: location) {
                            GSRLocationCell(location: location, openRoomCount: openRoomCounts[location.gid])
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 60)
        }
        .transition(.blurReplace)
    }
}
