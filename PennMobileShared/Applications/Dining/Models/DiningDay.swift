//
//  DiningDay.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/21/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

public struct DiningDay: Codable, Equatable {
    let date: String
    let meals: [Meal]

    enum CodingKeys: String, CodingKey {
        case date
        case meals = "dayparts"
    }
}
