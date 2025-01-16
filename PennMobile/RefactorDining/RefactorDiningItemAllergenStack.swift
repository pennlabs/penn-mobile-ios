//
//  RefactorDiningItemAllergenStack.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/15/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct RefactorDiningItemAllergenStack: View {
    let item: RefactorDiningItem
    let allergens: [RefactorDiningAllergen]
    init(_ item: RefactorDiningItem) {
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
