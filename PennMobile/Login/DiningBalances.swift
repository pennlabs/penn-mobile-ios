//
//  DiningBalances.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 3/31/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class DiningBalances: Codable {
    var hasDiningPlan: Bool
    var planName: String?
    var diningDollars: String?
    var visits: Int?
    var guestVisits: Int?
    
    init(hasDiningPlan: Bool, planName: String?, diningDollars: String?, visits: Int?, guestVisits: Int?) {
        self.hasDiningPlan = hasDiningPlan
        self.planName = planName
        self.diningDollars = diningDollars
        self.visits = visits
        self.guestVisits = guestVisits
    }
}
