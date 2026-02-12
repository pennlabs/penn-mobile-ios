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
    @State var groupShareString: String = ""
    
    var body: some View {
        NavigationStack {
            reservationContent
        }
    }
    
    @ViewBuilder
    private var reservationContent: some View {
        let groupedReservations = Dictionary(grouping: vm.currentReservations) { res in
            Calendar.current.startOfDay(for: res.start)
        }

        if !vm.currentReservations.isEmpty {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(groupedReservations.keys.sorted(), id: \.self) { date in
                        Text(date.gsrReservationsViewHeaderString)
                            .font(.largeTitle)
                            .bold()

                        ForEach(groupedReservations[date] ?? []) { res in
                            NavigationLink(
                                destination: GSRReservationDetailView(gsrReservation: res)
                            ) {
                                ReservationCell(reservation: res)
                            }
                            Divider()
                        }
                    }
                }
                .padding()
            }
            .refreshable {
                vm.currentReservations = (try? await GSRNetworkManager.getReservations()) ?? []
            }
        } else {
            VStack {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 58))
                        .foregroundColor(.gray.opacity(0.45))
                        .padding(.bottom, 4)

                    Text("No Upcoming Reservations")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("Your booked study rooms will appear here.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 24)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 80)
            }
            .padding()
        }
    }
}

extension Date {
    var gsrReservationsViewHeaderString: String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        }
        
        if Calendar.current.isDateInTomorrow(self) {
            return "Tomorrow"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
        
    }
}


