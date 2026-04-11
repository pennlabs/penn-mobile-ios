//
//  RefactorDiningItemAllergenStack.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/15/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct DiningItemAllergenStack: View {
    let item: DiningStationItem
    let allergens: [DiningAllergen]
    init(_ item: DiningStationItem) {
        self.item = item
        allergens = item.getAllergens()
    }
    
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(allergens, id: \.self) { allergen in
                Image(allergen.imagePath)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(maxHeight: 20)
    }
}
