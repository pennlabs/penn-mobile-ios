//
//  Meal.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/21/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

public struct Meal: Codable, Equatable {
    public let starttime: Date
    public let endtime: Date
    public let label: String
}
