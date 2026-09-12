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
    @State private var vm = GSRViewModel()
    @State private var selectedTab: GSRTab = .book
    @State private var isMapView = false
    
    private var isShowingMessage: Binding<Bool> {
        Binding(get: { vm.message != nil }, set: { if !$0 { vm.message = nil } })
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                GSRTabPicker(selection: $selectedTab)
                
                switch selectedTab {
                case .book:
                    ZStack(alignment: .bottomTrailing) {
                        if isMapView {
                            GSRMapView(locations: vm.locations.standardGSRSort)
                        } else {
                            GSRLocationListView(locations: vm.locations.standardGSRSort, openRoomCounts: vm.openRoomCounts)
                        }
                        GSRMapToggleButton(isMapView: $isMapView)
                            .padding(20)
                    }
                case .reservations:
                    GSRReservationsView(
                        reservations: vm.reservations,
                        shareLinks: vm.shareLinks,
                        onRefresh: { await vm.refreshReservations() },
                        onAddToCalendar: { reservation in Task { await vm.addToCalendar(reservation) } },
                        onCancel: { reservation in Task { await vm.cancel(reservation) } }
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
            .task(id: vm.locations) {
                while !Task.isCancelled {
                    await vm.refreshOpenRoomCounts()
                    try? await Task.sleep(for: .seconds(90))
                }
            }
        }
        .alert(vm.message ?? "", isPresented: isShowingMessage) {
            Button("OK") {}
        }
    }
}
