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
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()

    private let timeFormatter: DateFormatter = {
        let tf = DateFormatter()
        tf.timeStyle = .short
        return tf
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Booking Details").font(.headline)

            HStack {
                Text("\(timeFormatter.string(from: model.start)) - \(timeFormatter.string(from: model.end))")
                    .detailChip()

                Text(dateFormatter.string(from: model.start))
                    .detailChip()
            }
        }
    }
}
