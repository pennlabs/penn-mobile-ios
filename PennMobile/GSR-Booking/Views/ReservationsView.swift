//
//  ReservationsView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 8/20/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher

struct ReservationsView: View {
    @EnvironmentObject var vm: GSRViewModel
    
    var body: some View {
        if !vm.currentReservations.isEmpty {
            ScrollView {
                VStack {
                    ForEach(vm.currentReservations) { res in
                        ReservationCell(reservation: res)
                        Divider()
                    }
                }
                .padding()
            }
            .refreshable {
                vm.currentReservations = (try? await GSRNetworkManager.getReservations()) ?? []
            }
        } else {
            VStack {
                Text("You have no upcoming reservations.")
                    .font(.title)
                    .fontWeight(.light)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(UIColor.systemGray))
                Spacer()
            }
            .padding()
            
            
        }
        
        
    }
}

struct ReservationCell: View {
    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.presentToast) var presentToast
    let reservation: GSRReservation
    
    let height: CGFloat = 100
    
    var body: some View {
        HStack {
            KFImage(URL(string: reservation.gsr.imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 80)
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack {
                Text(reservation.roomName)
                    .font(.system(size: 18))
                Text("\(reservation.start.gsrTimeString) - \(reservation.end.gsrTimeString)")
            }
            .padding(.leading, 16)
            Spacer()
            Button {
                Task {
                    withAnimation {
                        vm.currentReservations.removeAll(where: { $0.bookingId == reservation.bookingId })
                    }
                    
                    
                    do {
                        try await GSRNetworkManager.deleteReservation(reservation)
                    } catch {
                        presentToast(.init(message: "Unable to delete this reservation. Is it currently in progress?"))
                    }
                    let newReservations = (try? await GSRNetworkManager.getReservations()) ?? []
                    vm.currentReservations = newReservations
                }
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
                    .padding(4)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.red.opacity(0.2))
                    }
            }
        }
        .frame(height: height)
        .cornerRadius(8)
        .transition(.blurReplace)
    }
}
