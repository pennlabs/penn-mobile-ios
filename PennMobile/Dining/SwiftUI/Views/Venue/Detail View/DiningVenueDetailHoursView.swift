//
//  DiningVenueDetailHoursView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 23/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI

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

struct DiningVenueDetailHoursView_Previews: PreviewProvider {
    static var previews: some View {
        let path = Bundle.main.path(forResource: "sample-dining-venue", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let diningVenues = try! decoder.decode(DiningAPIResponse.self, from: data)
        return DiningVenueDetailHoursView(for: diningVenues.document.venues[0]).padding()
    }
}
