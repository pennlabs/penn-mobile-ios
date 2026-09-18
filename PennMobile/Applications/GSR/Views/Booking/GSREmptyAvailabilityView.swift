//
//  GSREmptyAvailabilityView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSREmptyAvailabilityView: View {
    var body: some View {
        VStack {
            Spacer()
            Image("EmptyStateGSR")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
            Text("No rooms available")
                .font(.title2)
                .fontWeight(.light)
            Spacer()
        }
    }
}
