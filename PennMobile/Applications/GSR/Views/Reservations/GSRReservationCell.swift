//
//  GSRReservationCell.swift
//  PennMobile
//
//  Created by Khoi Dinh on 12/10/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher
import PennMobileShared

struct GSRReservationCell: View {
    let reservation: GSRReservation
    let shareURL: URL?
    let onAddToCalendar: () -> Void
    let onCancel: () -> Void
    
    @Environment(\.openURL) private var openURL
    
    private var roomName: String {
        let splitRoom = String(reservation.roomName.split(separator: ":").first ?? "")
        guard splitRoom.hasPrefix("[Me]") else { return splitRoom }
        return splitRoom.dropFirst("[Me]".count).trimmingCharacters(in: .whitespaces)
    }
    
    private var shareTitle: String {
        "\(reservation.gsr.name) [\(roomName)]"
    }
    
    private var shareDateLine: String {
        let date = reservation.start.formatted(date: .numeric, time: .omitted)
        let start = reservation.start.formatted(date: .omitted, time: .shortened)
        let end = reservation.end.formatted(date: .omitted, time: .shortened)
        return "\(date) • \(start)–\(end)"
    }
    
    private var calendarTitle: String {
        "GSR Booking: \(reservation.gsr.name) \(reservation.roomName)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.5) {
            HStack {
                KFImage(URL(string: reservation.gsr.imageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                    )
                
                VStack(alignment: .leading) {
                    Text(roomName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("labelPrimary"))
                    
                    Text("\(reservation.start.gsrTimeString) - \(reservation.end.gsrTimeString)")
                        .font(.subheadline)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .background(Color("grey5"))
                        .foregroundStyle(Color("labelPrimary"))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .padding(.leading, 16)
                
                Spacer()
            }
            .frame(height: 100)
            
            HStack(spacing: 18) {
                Button(action: onAddToCalendar) {
                    Image("iCalendar")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 32, height: 32)
                }
                .modifier(GSRCircleActionStyle())
                
                Button {
                    if let url = GoogleCalendarLink.makeURL(title: calendarTitle, location: reservation.gsr.name, start: reservation.start, end: reservation.end) {
                        openURL(url)
                    }
                } label: {
                    Image("GoogleCalendar")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 32, height: 32)
                }
                .modifier(GSRCircleActionStyle())
                
                Spacer()
                
                Group {
                    if let shareURL {
                        ShareLink(
                            item: shareURL,
                            subject: Text("GSR Reservation"),
                            message: Text("\(shareTitle)\n\(shareDateLine)"),
                            preview: SharePreview("\(shareTitle) • \(shareDateLine)", image: Image(systemName: "calendar"))
                        ) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18, weight: .semibold))
                                .padding(.bottom, 2)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        ProgressView()
                    }
                }
                .modifier(GSRCircleActionStyle())
                
                Button(action: onCancel) {
                    Image(systemName: "trash")
                        .foregroundStyle(Color("baseRed"))
                        .fontWeight(.semibold)
                }
                .modifier(GSRCircleActionStyle())
            }
        }
        .padding(.top, 5)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }
}
