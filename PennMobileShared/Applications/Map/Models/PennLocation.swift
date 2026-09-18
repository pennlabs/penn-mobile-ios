//
//  PennLocation.swift
//  PennMobile
//
//  Created by Jacky on 10/9/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import CoreLocation

public struct PennLocation: Identifiable, Sendable {
    public let id = UUID()
    public let name: String
    public let coordinate: CLLocationCoordinate2D
}
