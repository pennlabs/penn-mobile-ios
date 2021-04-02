//
//  DiningVenueDetailLocationView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 23/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI
import MapKit

@available(iOS 14.0, *)
struct DiningVenueDetailLocationView: View {
    
    @State private var region: MKCoordinateRegion
    let venue: DiningVenue
    
    init(for venue: DiningVenue) {
        self.venue = venue
        _region = .init(initialValue: PennCoordinate.shared.getRegion(for: venue, at: .mid))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description")
                .font(.system(size: 21, weight: .medium))
            Text(description)
                .font(.system(size: 17, weight: .light)).italic()
                .padding(.bottom, 10)
            
            Text("Location")
                .font(.system(size: 21, weight: .medium))
            
            // Enclosing venue in array as there are yet to be init methods for single annotation item
            Map(coordinateRegion: $region, annotationItems: [venue]) { venue in
                MapMarker(coordinate: PennCoordinate.shared.getCoordinates(for: venue))
            }
            // TODO: Figure out how to determine height dynamically to suit iPad Needs
            .frame(height: 232)
            .clipShape(RoundedRectangle(cornerRadius: 17))
            
            Spacer(minLength: 120)
        }
    }
}


// TODO Add description to backend
let description = """
“1920 Commons, the largest café on campus, is located on Locust Walk, right across the 38th Street Bridge. Serving lunch, lite lunch, and dinner during the week and brunch and dinner on weekends. Enjoy a bountiful, seasonal salad bar; made-to-order deli; fresh, hot pizzas; comfort cuisine; savory soups; chicken, veggie burgers and beef burgers grilled to perfection; an ever-changing action station; or delectable desserts. It’s all here!”
"""

@available(iOS 14.0, *)
struct DiningVenueDetailLocationView_Previews: PreviewProvider {
    static var previews: some View {
        let path = Bundle.main.path(forResource: "sample-dining-venue", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let diningVenues = try! decoder.decode(DiningAPIResponse.self, from: data)
        return DiningVenueDetailLocationView(for: diningVenues.document.venues[0]).padding(.horizontal, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
    }
}
