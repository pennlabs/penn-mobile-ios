//
//  GSRCalendarSectionView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 3/26/26.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct GSRCalendarSectionView: View {
    let model: GSRReservation
    let gsrLocation: String
    let roomName: String?

    @Environment(\.openURL) var openURL

    private var calendarTitle: String {
        "GSR Booking: \(gsrLocation) \(roomName ?? model.roomName)"
    }

    var body: some View {
        if model.end < Date() {
            Text("GSR Booking Expired")
                .foregroundColor(.red)
                .font(.system(size: 20, weight: .semibold))
                .padding(.vertical, 8)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Calendar Options")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.secondary)

                Button {
                    Task {
                        try? await CalendarHelper.addToCalendar(
                            title: calendarTitle,
                            location: gsrLocation,
                            start: model.start,
                            end: model.end
                        )
                    }
                } label: {
                    HStack {
                        Image("iCalendar")
                            .resizable()
                            .frame(width: 32, height: 32)
                        Spacer()
                        Text("Add to Apple Calendar")
                        Spacer()
                        Color.clear.frame(width: 24)
                    }
                }
                .modifier(CapsuleButtonStyle())

                Button {
                    if let url = GoogleCalendarLink.makeURL(
                        title: calendarTitle,
                        location: gsrLocation,
                        start: model.start,
                        end: model.end
                    ) {
                        openURL(url)
                    }
                } label: {
                    HStack {
                        Image("GoogleCalendar")
                            .resizable()
                            .frame(width: 34, height: 34)
                        Spacer()
                        Text("Add to Google Calendar")
                        Spacer()
                        Color.clear.frame(width: 24)
                    }
                }
                .modifier(CapsuleButtonStyle())
            }
        }
    }
}

struct CapsuleButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.primary.opacity(0.7))
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
    }
}
