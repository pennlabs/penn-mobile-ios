//
//  DataHour.swift
//  PennMobile
//
//  Created by Jordan H on 4/7/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import Foundation

public struct DataHour: Identifiable {
    public let date: Date
    public let value: Double
    public var id: Date { date }
}
