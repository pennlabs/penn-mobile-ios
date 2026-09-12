//
//  DiningPlan.swift
//  PennMobile
//
//  Created by Jordan H on 10/18/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

public struct DiningPlan: Codable, Sendable {
    public let name: String
    public let description: String
    public let start_date: Date
    public let end_date: Date
    public let signup_date: Date
    public let cost: String
    public let dining_dollars: String
    public let total_visits: Int
}
