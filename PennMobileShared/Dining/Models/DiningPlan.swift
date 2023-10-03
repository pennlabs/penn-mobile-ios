//
//  DiningPlan.swift
//  PennMobile
//
//  Created by Jordan H on 10/18/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

struct DiningPlan: Codable {
    let name: String
    let description: String
    let start_date: Date
    let end_date: Date
    let signup_date: Date
    let cost: String
    let dining_dollars: String
    let total_visits: Int
}
