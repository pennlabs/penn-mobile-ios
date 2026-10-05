//
//  QuickBookResultsBar.swift
//  PennMobile
//
//  Created by Laura Chen on 10/3/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI

/// Shown after Quick Book finds rooms: the current match, arrows to move between matches,
/// and a Book button. The match is already selected on the grid.
struct QuickBookResultsBar: View {
    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.presentToast) var presentToast
    @Environment(\.gsrUnderlyingVerticalProxy) var vertProxy
    @Environment(\.colorScheme) var colorScheme
    @State var isBooking = false

    var body: some View {
        if let match = vm.currentQuickBookMatch {
            let count = vm.quickBookResults.count

            VStack(alignment: .leading, spacing: 12) {
                if !match.isExact {
                    Label("No exact match. Showing nearby times.", systemImage: "clock.arrow.2.circlepath")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(alignment: .top) {
                    // Tapping the description goes back to the picker to change the time
                    Button {
                        vm.editQuickBookSearch()
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(match.room.roomNameShort)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(timeText(for: match))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .contentTransition(.numericText())
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Change the time")

                    Spacer()

                    Button {
                        vm.endQuickBook(clearSelection: true)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Close Quick Book")
                }

                HStack(spacing: 8) {
                    arrowButton(systemImage: "chevron.left", label: "Previous room") {
                        vm.showQuickBookMatch(at: vm.quickBookIndex - 1)
                    }
                    .disabled(count < 2)

                    Text("\(vm.quickBookIndex + 1) of \(count)")
                        .font(.subheadline)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .frame(minWidth: 56)

                    arrowButton(systemImage: "chevron.right", label: "Next room") {
                        vm.showQuickBookMatch(at: vm.quickBookIndex + 1)
                    }
                    .disabled(count < 2)

                    Spacer()

                    Button {
                        Task { await book() }
                    } label: {
                        Group {
                            if isBooking {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Book")
                            }
                        }
                        .font(.body.bold())
                        .foregroundStyle(Color.white)
                        .frame(minWidth: 72)
                        .padding(12)
                        .padding(.horizontal, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(Color("gsrBlue"))
                        }
                    }
                    .disabled(isBooking)
                }
            }
            .padding()
            .frame(maxWidth: 500)
            .background {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.thickMaterial)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                        .shadow(radius: 2)
                }
            }
            .onAppear { scroll(to: match) }
            .onChange(of: match) { _, new in scroll(to: new) }
        }
    }

    func arrowButton(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.bold())
                .frame(width: 44, height: 44)
                .background {
                    Circle()
                        .foregroundStyle(Color("gsrAvailable"))
                }
        }
        .accessibilityLabel(label)
    }

    /// "9:00 AM – 10:30 AM", plus how far it moved for a nearby time.
    func timeText(for match: QuickBookMatch) -> String {
        let range = "\(match.start.gsrTimeString) – \(match.end.gsrTimeString)"
        guard !match.isExact else { return range }
        let shift = QuickBookTimelinePicker.durationText(minutes: abs(match.offsetMinutes))
        return "\(range) · \(shift) \(match.offsetMinutes < 0 ? "earlier" : "later")"
    }

    /// Scrolls the grid to the match. `scrollTo` only moves the first scroll view that contains the target,
    /// so this takes two calls: the room's label lives only in the vertical scroll view (moves up/down),
    /// and its time slot lives in the horizontal one (moves sideways).
    /// y: 0.35 keeps the row above this bar; x: 0.25 puts the first slot just right of the room names.
    func scroll(to match: QuickBookMatch) {
        guard let proxy = vertProxy?.proxy, let firstSlot = match.slots.first else { return }
        withAnimation(.snappy) {
            proxy.scrollTo(RoomRowAnchor(room: match.room), anchor: UnitPoint(x: 0, y: 0.35))
            proxy.scrollTo(RoomTimeslot(room: match.room, timeslot: firstSlot), anchor: UnitPoint(x: 0.25, y: 0.5))
        }
    }

    func book() async {
        isBooking = true
        do {
            try await vm.book()
        } catch {
            presentToast(.init(message: "\(error.localizedDescription)"))
        }
        isBooking = false
    }
}
