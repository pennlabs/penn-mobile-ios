//
//  GSRCalendarSectionView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 3/26/26.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRCalendarSectionView: View {
    let model: GSRReservation
    let gsrLocation: String
    let roomName: String?
    
    @Environment(\.presentToast) var presentToast
    @Environment(\.openURL) var openURL
    
    var body: some View {
        if model.end < Date() {
            Text("GSR Booking Expired")
                .foregroundColor(.red)
                .font(.system(size: 20, weight: .semibold))
                .padding(.vertical, 8)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Calendar Options").font(.headline)

                Button {
                    Task {
                        do {
                            try await CalendarHelper.addToCalendar(
                                title: "GSR Booking: \(gsrLocation) \(roomName ?? model.roomName)",
                                location: gsrLocation,
                                start: model.start,
                                end: model.end
                            )
                            presentToast(.init(message: "Added to calendar!"))
                        } catch CalendarError.accessDenied {
                            presentToast(.init(message: "Calendar access denied. Please enable it in Settings."))
                        } catch {
                            presentToast(.init(message: "Failed to add event to calendar."))
                        }
                    }
                } label: {
                    Label("Add to Calendar", systemImage: "calendar")
                        .calendarButton(style: .blueFilled)
                }

                Button {
                    if let url = GoogleCalendarLink.makeURL(
                        title: "GSR Booking: \(gsrLocation) \(roomName ?? model.roomName)",
                        location: gsrLocation,
                        start: model.start,
                        end: model.end
                    ) {
                        openURL(url)
                    }
                } label: {
                    Label("Google Calendar", systemImage: "calendar")
                        .calendarButton(style: .whiteOutline)
                }
            }
        }
    }
}
