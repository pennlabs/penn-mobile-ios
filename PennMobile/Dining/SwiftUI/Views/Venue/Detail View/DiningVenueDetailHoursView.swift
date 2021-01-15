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
        VStack(alignment: .leading, spacing: 7) {
            Text("Hours this week")
                .font(.system(size: 21, weight: .regular))

            ForEach(0..<7) { duration in
                let date = Date().dateIn(days: duration)
                let formattedString = venue.formattedHoursStringFor(date)
                
                HStack {
                    Text("\(date.dayOfWeek)" + (duration == 0 ? " (Today)" : ""))
                        .font(.system(size: 17, weight: .regular))
                    
                    Spacer()
                    
                    Text(formattedString != "" ? formattedString : "Closed")
                        .font(.system(size: 17, weight: .thin))
                }
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
