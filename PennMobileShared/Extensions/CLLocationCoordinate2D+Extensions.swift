//
//  CLLocationCoordinate2D+Extensions.swift
//  PennMobileShared
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import MapKit

extension CLLocationCoordinate2D: @retroactive Identifiable {
    public var id: String {
        return "\(latitude)-\(longitude)"
    }
}
