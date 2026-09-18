//
//  PastDiningBalances.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 3/25/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

public struct PastDiningBalances: Codable, Sendable {
    public let balanceList: [DiningBalance]
}
