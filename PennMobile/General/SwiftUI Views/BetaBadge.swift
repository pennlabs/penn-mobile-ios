//
//  BetaBadge.swift
//  PennMobile
//
//  Created by Anthony Li on 4/19/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

struct BetaBadge: View {
    var body: some View {
        // There is a good reason for this trust me
        // (It's so that the spacing matches the font size)
        Text("  Beta  ")
            .fixedSize(horizontal: true, vertical: false)
            .fontWeight(.medium)
            .textCase(.uppercase)
            .blendMode(.destinationOut)
            .background(.foreground)
            .clipShape(.capsule)
            .compositingGroup()
            .multilineTextAlignment(.leading)
    }
}

#Preview {
    HStack {
        Text("Penn Mobile Sublet")
        BetaBadge()
        Text("is here!")
    }
    .font(.title3)
    .padding()
}
