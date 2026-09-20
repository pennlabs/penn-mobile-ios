//
//  GSRBookingDetailsView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 3/26/26.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRBookingDetailsView: View {
    let model: GSRReservation
    
    private let fullDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMMM d, yyyy"
        return df
    }()

    private let timeFormatter: DateFormatter = {
        let tf = DateFormatter()
        tf.dateFormat = "h:mm a"
        tf.locale = Locale(identifier: "en_US_POSIX")
        return tf
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Booking Details")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.secondary)

            Text(fullDateFormatter.string(from: model.start))
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)

            Text("\(timeFormatter.string(from: model.start)) to \(timeFormatter.string(from: model.end))")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}
