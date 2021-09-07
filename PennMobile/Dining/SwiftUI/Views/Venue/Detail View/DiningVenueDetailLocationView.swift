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
    let mapHeight: CGFloat
    
    init(for venue: DiningVenue, screenHeight: CGFloat) {
        self.venue = venue
        mapHeight = screenHeight - 20
        _region = .init(initialValue: PennCoordinate.shared.getRegion(for: venue, at: .mid))
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [venue]) { venue in
            MapMarker(coordinate: PennCoordinate.shared.getCoordinates(for: venue))
        }.clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
        .frame(height: mapHeight)
    }
}

@available(iOS 14.0, *)
struct DiningVenueDetailLocationView_Previews: PreviewProvider {
    static var previews: some View {
        let path = Bundle.main.path(forResource: "sample-dining-venue", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let diningVenues = try! decoder.decode(DiningAPIResponse.self, from: data)
        return DiningVenueDetailLocationView(for: diningVenues.document.venues[0], screenHeight: 600).padding(.horizontal, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
    }
}
