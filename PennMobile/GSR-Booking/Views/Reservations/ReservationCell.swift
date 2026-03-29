//
//  ReservationCell.swift
//  PennMobile
//
//  Created by Khoi Dinh on 12/10/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//
import SwiftUI
import Kingfisher
import PennMobileShared

struct ReservationCell: View {
    let reservation: GSRReservation
    
    let height: CGFloat = 100
    
    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.presentToast) var presentToast
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
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
                        .foregroundStyle(.labelPrimary)
                    
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
                if FeatureFlags.shared.gsrShare {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                } else {
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
                        Label("", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .frame(height: height)
            .cornerRadius(8)
            .transition(.blurReplace)
        }
        .padding()
    }
}

