//
//  DiningVenueDetailLocationView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 23/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI
import MapKit
import PennMobileShared

struct DiningVenueDetailLocationView: View {

    @State private var region: MKCoordinateRegion
    let venue: DiningVenue
    let mapHeight: CGFloat

    init(for venue: DiningVenue, screenHeight: CGFloat) {
        self.venue = venue
        mapHeight = screenHeight - 20
        _region = .init(initialValue: PennLocation.getRegion(for: venue, at: .mid))
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [venue]) { venue in
            MapMarker(coordinate: PennLocation.getCoordinates(for: venue))
        }.clipShape(RoundedRectangle(cornerRadius: 25.0))
        .frame(height: mapHeight)
    }
}
