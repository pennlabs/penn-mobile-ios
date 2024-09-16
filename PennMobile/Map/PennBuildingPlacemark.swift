//
//  PennBuildingPlacemark.swift
//  PennMobile
//
//  Created by Dominic Holmes on 8/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import MapKit

class PennBuildingPlacemark: MKPlacemark {

    init(coordinate: CLLocationCoordinate2D, venue: DiningVenueName) {
        self.title = DiningVenueName.getVenueName(for: venue)
        self.subtitle = "Penn Dining"
        super.init(coordinate: coordinate)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
