//
//  CalendarCardView.swift
//  PennMobile
//
//  Created by Anthony Li on 10/21/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct CalendarCardView: View {
    var events: [CalendarEvent]
    
    var body: some View {
        HomeCardView {
            VStack(alignment: .leading, spacing: 20) {
                Text("\(Image(systemName: "calendar")) University Calendar")
                    .textCase(.uppercase)
                    .fontWeight(.medium)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                ForEach(Array(events.enumerated()), id: \.0) { item in
                    let event = item.1
                    
                    HStack(spacing: 8) {
                        Image("upenn")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                        VStack(alignment: .leading) {
                            Text(event.event)
                                .font(.headline)
                                .fontWeight(.medium)
                            Text(event.date)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
            .padding(.bottom, 20)
        }
    }
}
