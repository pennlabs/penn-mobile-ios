//
//  GSRReservationAnnouncementView.swift
//  PennMobile
//
//  Created by Mati Okutsu on 10/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher

struct ReservationAnnouncementView: View {
    let reservation: GSRReservation
    
    let height: CGFloat = 100
    let icon = "bell.fill"
    
    var body: some View {

            VStack(alignment: .leading) {
                HStack {
                    Text("\(Image(systemName: icon)) GSR RESERVATION")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    Spacer()
                    
                    Text("\((Calendar.current.startOfDay(for: reservation.start).gsrReservationsViewHeaderString).uppercased())")
                }
                .foregroundStyle(.secondary)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.bottom, 2)
                
                HStack {
                    KFImage(URL(string: reservation.gsr.imageUrl))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 80)
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading) {
                        Text(reservation.roomName)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        
                        Text("\(reservation.start.gsrTimeString) - \(reservation.end.gsrTimeString)")
                            .font(.subheadline)
                            .padding(.vertical, 3)
                            .padding(.horizontal, 6)
                            .foregroundColor(.labelPrimary)
                            .background(Color.secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .padding(.leading, 16)
                    Spacer()
                }
                .frame(height: height)
                .cornerRadius(8)
                .transition(.blurReplace)
            }
            .padding()
        }
}



#Preview(traits: .sizeThatFitsLayout) {
        HomeCardView {
            ReservationAnnouncementView(reservation: GSRReservation(bookingId: "123", gsr: GSRLocation(lid: "123", gid: 123, name: "Van Pelt", kind: .libcal, imageUrl: "https://www.cnet.com/a/img/resize/2bec42558a71a3922e6e590476b919288a015288/hub/2017/06/01/a176bcb9-1442-4d6d-a7d9-f01efdbcc4bc/broken-screen-ipad-6200-002.jpg?auto=webp&fit=crop&height=675&width=1200", bookableDays: 7), roomId: 123, roomName: "Room 250: A. Edward Allinson Group Study Room", start: Calendar.current.date(
                bySettingHour: 14, minute: 0, second: 0, of: Date()
            )!, end: Calendar.current.date(
                bySettingHour: 15, minute: 30, second: 0, of: Date()
            )!))
        }
}
