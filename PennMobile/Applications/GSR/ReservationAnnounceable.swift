//
//  ReservationAnnounceable.swift
//  PennMobile
//
//  Created by Mati Okutsu on 10/26/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation
import PennMobileShared

struct ReservationAnnounceable: HomeViewAnnounceable {
    func getHomeViewAnnouncements() async -> [HomeViewAnnouncement] {
        let reservations = await PennMobileApplication.GSR.GetReservations().execute(shouldSilentlyFail: true).unwrap() ?? []
        
        guard let earliest = reservations.min(by: { $0.start < $1.start }),
              Calendar.current.isDateInToday(earliest.start) || Calendar.current.isDateInTomorrow(earliest.start) else {
            return []
        }
        
        return [
            HomeViewAnnouncement(analyticsSlug: nil, disappearOnTap: false, priority: .medium) {
                GSRReservationAnnouncementView(reservation: earliest)
            }
        ]
    }
}
