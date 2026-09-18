//
//  GSRTab.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 2/19/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

enum GSRTab: Int, CaseIterable {
    case book
    case reservations
    
    var titleText: String {
        switch self {
        case .book: "Book"
        case .reservations: "Reservations"
        }
    }
}
