//
//  GSRReservationsView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 8/20/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct GSRReservationsView: View {
    let reservations: [GSRReservation]
    let shareLinks: [String: URL]
    let onRefresh: () async -> Void
    let onAddToCalendar: (GSRReservation) -> Void
    let onCancel: (GSRReservation) -> Void
    
    var body: some View {
        if reservations.isEmpty {
            GSRNoReservationsView()
        } else {
            let groupedReservations = Dictionary(grouping: reservations) { Calendar.current.startOfDay(for: $0.start) }
            
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(groupedReservations.keys.sorted(), id: \.self) { date in
                        Text(date.gsrReservationsViewHeaderString)
                            .font(.largeTitle)
                            .bold()
                        ForEach(groupedReservations[date] ?? []) { reservation in
                            GSRReservationCell(
                                reservation: reservation,
                                shareURL: shareLinks[reservation.bookingId],
                                onAddToCalendar: { onAddToCalendar(reservation) },
                                onCancel: { onCancel(reservation) }
                            )
                            Divider()
                        }
                    }
                }
                .padding()
            }
            .refreshable {
                await onRefresh()
            }
        }
    }
}
