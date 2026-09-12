//
//  GSRBookingView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct GSRBookingView: View {
    @Bindable var vm: GSRViewModel
    let initialLocation: GSRLocation
    let onViewReservations: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private var location: Binding<GSRLocation?> {
        Binding(get: { vm.selectedLocation }, set: { if let location = $0 { vm.selectLocation(location) } })
    }
    
    private var isShowingBookingSuccess: Binding<Bool> {
        Binding(get: { vm.recentBooking != nil }, set: { if !$0 { vm.recentBooking = nil } })
    }
    
    var body: some View {
        VStack {
            Picker("Location", selection: location) {
                ForEach(vm.locations.standardGSRSort, id: \.self) { location in
                    Text(location.name)
                        .tag(Optional(location))
                }
            }
            .padding(.horizontal)
            
            Picker("Date", selection: $vm.selectedDate) {
                ForEach(vm.datePickerOptions, id: \.self) { option in
                    Text(option.localizedGSRText)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if vm.isLoadingAvailability {
                GSRLoadingView()
            } else if vm.hasAvailableBooking {
                GSRTwoWayScrollView(
                    rooms: vm.displayedRooms,
                    headerTimes: vm.headerTimes,
                    availableStartTimes: vm.availableStartTimes,
                    sortedStartTimes: vm.sortedStartTimes,
                    selectedSlotIDs: vm.selectedSlotIDs,
                    onToggleSlot: { slot, room in
                        withAnimation(.spring(duration: 0.2)) {
                            vm.toggleTimeslot(slot, in: room)
                        }
                    },
                    onToggleSort: { time in
                        withAnimation(.snappy(duration: 0.3)) {
                            vm.toggleSort(at: time)
                        }
                    }
                )
                .overlay(alignment: .bottom) {
                    GSRBookingToolbarView(
                        hasSelection: !vm.selectedTimeslots.isEmpty,
                        hasSortFilters: !vm.sortedStartTimes.isEmpty,
                        onBook: { Task { await vm.book() } },
                        onResetFilters: {
                            withAnimation(.snappy(duration: 0.3)) {
                                vm.clearSortFilters()
                            }
                        }
                    )
                    .padding(24)
                }
            } else {
                GSREmptyAvailabilityView()
            }
        }
        .navigationTitle("Choose a Time Slot")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                GSRSettingsButton(showFullyUnavailableRooms: $vm.showFullyUnavailableRooms)
            }
        }
        .task {
            vm.selectLocation(initialLocation)
            await vm.updateAvailability()
        }
        .onChange(of: vm.selectedLocation) {
            Task { await vm.updateAvailability() }
        }
        .onChange(of: vm.selectedDate) {
            Task { await vm.updateAvailability() }
        }
        .alert("Booking Successful", isPresented: isShowingBookingSuccess, presenting: vm.recentBooking) { _ in
            Button("Okay") {
                dismiss()
            }
            Button("View Booking") {
                dismiss()
                onViewReservations()
            }
        } message: { booking in
            Text("You've successfully made a reservation for \(booking.roomName)")
        }
    }
}
