//
//  GSRView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 2/19/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct GSRView: View {
    @StateObject private var vm = GSRViewModel()
    @State private var selectedTab: GSRTab = .book
    @State private var message: String?
    
    private var isShowingMessage: Binding<Bool> {
        Binding(get: { message != nil }, set: { if !$0 { message = nil } })
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                GSRTabPicker(selection: $selectedTab)
                
                switch selectedTab {
                case .book:
                    ZStack(alignment: .bottomTrailing) {
                        if vm.isMapView {
                            GSRMapView(locations: vm.availableLocations.standardGSRSort)
                        } else {
                            GSRLocationListView(locations: vm.availableLocations.standardGSRSort, openRoomCounts: vm.gsrGetLastPulledAvailability.mapValues(\.availCount))
                        }
                        GSRMapToggleButton(isMapView: $vm.isMapView)
                            .padding(20)
                    }
                case .reservations:
                    GSRReservationsView(
                        reservations: vm.currentReservations,
                        shareLinks: vm.shareLinks,
                        onRefresh: { await vm.refreshReservations() },
                        onAddToCalendar: { reservation in Task { await addToCalendar(reservation) } },
                        onCancel: { reservation in Task { await vm.cancelReservation(reservation) } }
                    )
                    .transition(.blurReplace)
                    .task { await vm.refreshReservations() }
                }
            }
            .navigationTitle("GSR Booking")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: GSRLocation.self) { location in
                GSRBookingView(vm: vm, initialLocation: location) {
                    selectedTab = .reservations
                }
            }
            .task { await vm.fetchInitialState() }
            .task(id: vm.availableLocations) {
                while !Task.isCancelled {
                    await vm.refreshOpenRoomCounts()
                    try? await Task.sleep(for: .seconds(90))
                }
            }
        }
        .alert(message ?? "", isPresented: isShowingMessage) {
            Button("OK") {}
        }
    }
    
    private func addToCalendar(_ reservation: GSRReservation) async {
        do {
            try await CalendarHelper.addToCalendar(
                title: "GSR Booking: \(reservation.gsr.name) \(reservation.roomName)",
                location: reservation.gsr.name,
                start: reservation.start,
                end: reservation.end
            )
            message = "Added to calendar!"
        } catch CalendarError.accessDenied {
            message = "Calendar access denied. Please enable it in Settings."
        } catch {
            message = "Failed to add event to calendar."
        }
    }
}
