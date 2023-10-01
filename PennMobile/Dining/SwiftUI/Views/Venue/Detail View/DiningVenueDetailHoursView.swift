//
//  DiningVenueDetailHoursView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 23/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI
import PennSharedCode

struct DiningVenueDetailHoursView: View {

    init(for venue: DiningVenue) {
        self.venue = venue
    }

    let venue: DiningVenue

    var body: some View {
        // TODO: Add level of business using public APIs Penn Dining will provide
        VStack(alignment: .leading, spacing: 7) {
            ForEach(0..<7) { duration in
                let dateInt = (7 - Date().integerDayOfWeek + duration) % 7
                let date = Date().dateIn(days: dateInt)

                Text("\(date.dayOfWeek)")
                    .font(duration == Date().integerDayOfWeek ? .system(size: 18, weight: .bold): .system(size: 18, weight: .regular))

                HStack {
                    ForEach(venue.formattedHoursArrayFor(date), id: \.self) { hours in
                        Text(hours)
                            .padding(.vertical, 3)
                            .padding(.horizontal, 4)
                            .font(.system(size: 14, weight: .light, design: .default))
                            .background(Color.grey5)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }

                    Spacer()
                }.offset(y: -4)
            }
        }
    }
}
