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
        
//        VStack(alignment: .leading) {
//            Text("Description")
//                .font(.system(size: 21, weight: .medium))
//                .padding(.bottom)
//
//            Text(description)
//                .font(.system(size: 17, weight: .light)).italic()
//
//        }
//
        HStack {
            VStack(alignment: .leading) {
                Text("Usual Weekly Hours")
                    .font(.system(size: 21, weight: .medium))
                    .padding(.bottom)

                Text(venue.formattedHoursStringFor(Date().dateIn(days: 9)))

    //            ForEach(venue.formattedHoursArrayFor(Date().dateIn(days: 2)), id: \.self) {
    //                Text($0)
    //            }
            }
//                    .background(Color.red)
            Spacer()
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
        return DiningVenueDetailHoursView(for: diningVenues.document.venues[0])
    }
}
