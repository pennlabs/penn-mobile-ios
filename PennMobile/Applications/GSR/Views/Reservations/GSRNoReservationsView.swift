//
//  GSRNoReservationsView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 8/20/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRNoReservationsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 58))
                .foregroundColor(.gray.opacity(0.45))
                .padding(.bottom, 4)

            Text("No Upcoming Reservations")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Your booked study rooms will appear here.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 80)
        .padding()
    }
}
