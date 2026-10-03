//
//  QuickBookTimelinePicker.swift
//  PennMobile
//
//  Created by Laura Chen on 10/3/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI

/// The Quick Book picker: a row of 30-minute blocks like the booking grid, each showing how many
/// rooms are open. The user picks back-to-back blocks, then taps Find.
struct QuickBookTimelinePicker: View {
    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.presentToast) var presentToast
    @Environment(\.colorScheme) var colorScheme

    static let cellWidth: CGFloat = 64

    var body: some View {
        let slots = vm.quickBookPickerSlots

        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pick a time")
                        .font(.headline)
                    Text(summaryText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                }
                Spacer()
                Button {
                    vm.endQuickBook(clearSelection: true)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Close")
            }

            if slots.isEmpty {
                Text("No more times left on this day.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(slots) { slot in
                            cell(for: slot)
                        }
                    }
                }
            }

            findButton
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
    }

    @ViewBuilder func cell(for slot: GSRTimeSlot) -> some View {
        let count = GSRQuickBookSearch.openCount(at: slot.startTime, in: vm.roomsAtSelectedLocation)
        let isSelected = vm.quickBookRequest.contains(slot.startTime)
        let shape = RoundedRectangle(cornerRadius: 6)

        VStack(spacing: 4) {
            Text(slot.startTime.gsrTimeString)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .fixedSize()

            ZStack {
                shape
                    .fill(isSelected ? Color("gsrBlue") : count > 0 ? Color("gsrAvailable") : Color("gsrUnavailable"))
                if count == 0 && !isSelected {
                    UnavailableTextureOverlay()
                        .clipShape(shape)
                }
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .offset(y: -10)
                }
                Text("\(count)")
                    .font(.headline)
                    .foregroundStyle(isSelected ? .white : count > 0 ? .primary : .secondary)
                    .offset(y: isSelected ? 6 : 0)
            }
            .frame(width: Self.cellWidth, height: 48)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            do {
                try vm.toggleQuickBookSlot(slot.startTime)
            } catch {
                presentToast(.init(message: "\(error.localizedDescription)"))
            }
        }
        .accessibilityElement()
        .accessibilityLabel(Text(slot.startTime.gsrTimeString))
        .accessibilityValue(Text("\(count) room\(count == 1 ? "" : "s") open\(isSelected ? ", selected" : "")"))
        .accessibilityAddTraits(.isToggle)
    }

    var findButton: some View {
        let exact = vm.quickBookExactMatches.count
        let nearby = exact == 0 ? vm.quickBookNearbyMatches.count : 0
        let isDisabled = vm.quickBookRequest.isEmpty || (exact == 0 && nearby == 0)

        let label: String = if vm.quickBookRequest.isEmpty {
            "Pick a time"
        } else if exact > 0 {
            "Find · \(exact) room\(exact == 1 ? "" : "s")"
        } else if nearby > 0 {
            "No exact match · See \(nearby) nearby time\(nearby == 1 ? "" : "s")"
        } else {
            "No rooms near this time"
        }

        return Button {
            vm.findQuickBookMatches()
        } label: {
            Label(label, systemImage: exact == 0 && nearby > 0 ? "clock.arrow.2.circlepath" : "magnifyingglass")
                .labelStyle(.titleAndIcon)
                .font(.body.bold())
                .foregroundStyle(isDisabled ? Color.secondary : Color.white)
                .contentTransition(.numericText())
                .frame(maxWidth: .infinity)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(isDisabled ? Color("gsrUnavailable") : Color("gsrBlue"))
                }
        }
        .disabled(isDisabled)
    }

    /// "2:00 – 3:30 PM · 1.5 hr", or a hint before anything is picked.
    var summaryText: String {
        guard let first = vm.quickBookRequest.first, let last = vm.quickBookRequest.last else {
            return "Tap up to \(Self.durationText(minutes: vm.maxQuickBookSlots * GSRQuickBookSearch.slotMinutes)) of back-to-back times"
        }
        let end = last.add(minutes: GSRQuickBookSearch.slotMinutes)
        let minutes = vm.quickBookRequest.count * GSRQuickBookSearch.slotMinutes
        return "\(first.gsrTimeString) – \(end.gsrTimeString) · \(Self.durationText(minutes: minutes))"
    }

    static func durationText(minutes: Int) -> String {
        switch (minutes / 60, minutes % 60) {
        case (0, let m): return "\(m) min"
        case (let h, 0): return "\(h) hr"
        default: return "\(String(format: "%.1f", Double(minutes) / 60)) hr"
        }
    }
}
