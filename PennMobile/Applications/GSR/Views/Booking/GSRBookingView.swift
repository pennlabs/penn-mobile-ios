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
    @ObservedObject var vm: GSRViewModel
    let initialLocation: GSRLocation
    let onViewReservations: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var message: String?

    private var location: Binding<GSRLocation?> {
        Binding(get: { vm.selectedLocation }, set: { if let location = $0 { setLocation(location) } })
    }

    private var isShowingMessage: Binding<Bool> {
        Binding(get: { message != nil }, set: { if !$0 { message = nil } })
    }

    private var displayedRooms: [GSRRoom] {
        vm.roomsAtSelectedLocation.compactMap { room in
            guard vm.settings.shouldShowFullyUnavailableRooms || room.availability.contains(where: \.isAvailable) else {
                return nil
            }
            var displayed = room
            displayed.availability = vm.getRelevantAvailability(room: room)
            return displayed
        }
    }

    private var headerTimes: [Date] {
        let slots = vm.getRelevantAvailability()
        guard let start = slots.first?.startTime else { return [] }
        return [start] + slots.map(\.endTime)
    }

    var body: some View {
        VStack {
            Picker("Location", selection: location) {
                ForEach(vm.availableLocations.standardGSRSort, id: \.self) { location in
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
                    rooms: displayedRooms,
                    headerTimes: headerTimes,
                    availableStartTimes: Set(vm.roomsAtSelectedLocation.flatMap { $0.availability.filter(\.isAvailable).map(\.startTime) }),
                    sortedStartTimes: vm.sortedStartTime,
                    selectedSlotIDs: Set(vm.selectedTimeslots.map { $0.1.id }),
                    onToggleSlot: { slot, room in
                        do {
                            try vm.handleTimeslotGesture(slot: slot, room: room)
                        } catch {
                            message = error.localizedDescription
                        }
                    },
                    onToggleSort: { time in
                        withAnimation(.snappy(duration: 0.3)) {
                            vm.handleSortAction(to: time)
                        }
                    }
                )
                .overlay(alignment: .bottom) {
                    GSRBookingToolbarView(
                        hasSelection: !vm.selectedTimeslots.isEmpty,
                        hasSortFilters: !vm.sortedStartTime.isEmpty,
                        onBook: {
                            Task {
                                do {
                                    try await vm.book()
                                } catch {
                                    message = error.localizedDescription
                                }
                            }
                        },
                        onResetFilters: {
                            withAnimation(.snappy(duration: 0.3)) {
                                vm.clearSortedFilters()
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
                GSRSettingsButton(showFullyUnavailableRooms: $vm.settings.shouldShowFullyUnavailableRooms)
            }
        }
        .onAppear {
            setLocation(initialLocation)
        }
        .onChange(of: vm.selectedDate) {
            Task { await vm.updateAvailability() }
        }
        .alert(message ?? "", isPresented: isShowingMessage) {
            Button("OK") {}
        }
        .alert("Booking Successful", isPresented: $vm.showSuccessfulBookingAlert, presenting: vm.recentBooking) { _ in
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

    private func setLocation(_ location: GSRLocation) {
        Task {
            do {
                try await vm.setLocation(to: location)
            } catch {
                message = error.localizedDescription
            }
        }
    }
}
