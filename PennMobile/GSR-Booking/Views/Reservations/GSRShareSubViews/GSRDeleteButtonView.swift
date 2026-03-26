//
//  GSRDeleteButtonView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 3/36/26.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRDeleteButtonView: View {
    let reservation: GSRReservation
    
    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.presentToast) var presentToast
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
            Task {
                withAnimation {
                    vm.currentReservations.removeAll { $0.bookingId == reservation.bookingId }
                }
                do {
                    try await GSRNetworkManager.deleteReservation(reservation)
                } catch {
                    presentToast(.init(message: "Unable to delete this reservation. Is it currently in progress?"))
                }
                vm.currentReservations = (try? await GSRNetworkManager.getReservations()) ?? []
                await MainActor.run { dismiss() }
            }
        } label: {
            Label("Delete Reservation", systemImage: "trash")
                .calendarButton(style: .redOutline)
                .foregroundColor(.red)
        }
    }
}
