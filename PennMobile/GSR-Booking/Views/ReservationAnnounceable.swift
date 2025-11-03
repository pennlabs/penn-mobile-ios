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
        
        for res in currentReservations {
            let reservationAnnouncement = HomeViewAnnouncement(analyticsSlug: nil, disappearOnTap: false, priority: .medium, linkedFeature: .gsr) {
                ReservationAnnouncementView(reservation: res)
            }
            
            if (Calendar.current.isDateInToday(res.start) || Calendar.current.isDateInTomorrow(res.start)) {
                homeViewAnnouncements.append(reservationAnnouncement)
            }
        }
        
        return homeViewAnnouncements
    }
}
