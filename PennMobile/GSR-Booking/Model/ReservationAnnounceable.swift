//
//  ReservationAnnouncementsModel.swift
//  PennMobile
//
//  Created by Mati Okutsu on 10/26/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//
import Foundation

 class ReservationAnnounceable: HomeViewAnnounceable {
    func getHomeViewAnnouncements () async -> [HomeViewAnnouncement] {
        var homeViewAnnouncements: [HomeViewAnnouncement] = []
        let currentReservations = (try? await GSRNetworkManager.getReservations()) ?? []
        
        let earliestRes = currentReservations.min(by: { $0.start < $1.start })
        
        if let earliestRes = earliestRes {
            if (Calendar.current.isDateInToday(earliestRes.start) || Calendar.current.isDateInTomorrow(earliestRes.start)) {
                let reservationAnnouncement = HomeViewAnnouncement(analyticsSlug: nil, disappearOnTap: false, priority: .medium, linkedFeature: .gsr) {
                        ReservationAnnouncementView(reservation: earliestRes)
                }
                homeViewAnnouncements.append(reservationAnnouncement)
            }
        }
        
        return homeViewAnnouncements
    }
}
