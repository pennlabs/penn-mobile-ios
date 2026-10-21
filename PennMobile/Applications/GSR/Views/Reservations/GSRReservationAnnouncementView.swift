//
//  GSRReservationAnnouncementView.swift
//  PennMobile
//
//  Created by Mati Okutsu on 10/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher
import PennMobileShared

struct GSRReservationAnnouncementView: View {
    let reservation: GSRReservation
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(Image(systemName: "bell.fill")) GSR Reservation")
                Spacer()
                Text(Calendar.current.startOfDay(for: reservation.start).gsrReservationsViewHeaderString)
            }
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.bottom, 2)
            
            HStack(spacing: 16) {
                KFImage(URL(string: reservation.gsr.imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 80)
                    .clipShape(.rect(cornerRadius: 8))
                
                VStack(alignment: .leading) {
                    Text(reservation.roomName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("\(reservation.start.gsrTimeString) - \(reservation.end.gsrTimeString)")
                        .font(.subheadline)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .background(Color("uiBackgroundSecondary"))
                        .clipShape(.rect(cornerRadius: 6))
                }
                Spacer()
            }
        }
        .padding()
    }
}
