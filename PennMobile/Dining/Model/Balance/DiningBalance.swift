//
//  DiningBalances.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 3/31/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct DiningBalance: Codable {
    let diningDollars: Float
    let visits: Int
    let guestVisits: Int
    let lastUpdated: Date
    
//    var hasDiningPlan: Bool
//    var lastUpdated: Date?
//    var planName: String?
//    var diningDollars: String?
//    var visits: Int?
//    var addOnVisits: Int?
//    var guestVisits: Int?
//    var totalVisits: Int?
//
//    init(hasDiningPlan: Bool, lastUpdated: Date?, planName: String?, diningDollars: String?, visits: Int?, addOnVisits: Int?, guestVisits: Int?) {
//        self.hasDiningPlan = hasDiningPlan
//        self.lastUpdated = lastUpdated
//        self.planName = planName
//        self.diningDollars = diningDollars
//        self.visits = visits
//        self.addOnVisits = addOnVisits
//        self.guestVisits = guestVisits
//        if let visits = visits, let addOnVisits = addOnVisits {
//            self.totalVisits = visits + addOnVisits
//        } else {
//            self.totalVisits = nil
//        }
//    }
}
