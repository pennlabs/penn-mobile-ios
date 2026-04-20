//
//  RoomFinderSelectionPanel.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 4/7/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

struct RoomFinderSelectionPanel: View {
    @ObservedObject var vm: GSRViewModel
    @StateObject var quickBook: GSRQuickBook
    @Binding var isEnabled: Bool
    @State var expectedWidth: CGFloat?
    @State var feedbackGenerator: UIImpactFeedbackGenerator? = nil
    @State var durationOptions: [Int] = []
    
    @State var minTimeRequirement: Int?
    @State var maxTimeRequirement: Int?
    @State var earliestTimeRequirement: Date?
    @State var latestTimeRequirement: Date?
            
    let formatter = DateFormatter()
    
    private func textWidth(_ text: String, font: UIFont = .preferredFont(forTextStyle: .body)) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return ceil(size.width)
    }
    
    private var panelWidth: CGFloat? {
        textWidth("Find me a room") + 24 * 2
    }
    
    init(vm: GSRViewModel, isEnabled: Binding<Bool>) {
        _quickBook = StateObject(wrappedValue: GSRQuickBook(vm: vm))
        self._vm = ObservedObject(initialValue: vm)
        self._isEnabled = isEnabled
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
    }
    
    var body: some View {
        VStack {
            Spacer()
            if let panelWidth, isEnabled {
                VStack {
                    Spacer()
                    Text("Duration")
                        .foregroundColor(Color("gsrBlue"))
                    Picker("", selection: $minTimeRequirement) {
                        ForEach(durationOptions, id: \.self) { option in
                            Text("\(String(option))m")
                                .tag(option)
                            }
                        .font(.caption)
                        .foregroundStyle(Color("gsrBlue"))
                    }
                    .pickerStyle(.menu)
                    Spacer()
                    Divider()
                    Spacer()
                    Text("Time")
                        .foregroundColor(Color("gsrBlue"))
                    Picker("", selection: $earliestTimeRequirement) {
                        ForEach(vm.getRelevantAvailability()) { slot in
                            Text(formatter.string(from: slot.startTime))
                                .tag(slot.startTime)
                        }
                        .font(.caption)
                        .foregroundStyle(Color("gsrBlue"))
                    }
                    Spacer()
                }
                .mask {
                    RoundedRectangle(cornerRadius: 12).frame(width: panelWidth, height: panelWidth)
                }
                .frame(width: panelWidth, height: panelWidth)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(Color.white)
                        .shadow(radius: 2)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                
            }
            Button {
                withAnimation(.snappy(duration: 0.2)) {
                    isEnabled.toggle()
                }
                if (!isEnabled) {
                    guard let location = vm.selectedLocation, let duration = minTimeRequirement, let time = earliestTimeRequirement else {
                        return
                    }
                    Task { @MainActor in
                        quickBook.onQuickBookSuccess = { booking in
                            vm.recentBooking = booking
                            Task {
                                vm.currentReservations = (try? await GSRNetworkManager.getReservations()) ?? []
                            }
                            vm.showSuccessfulBookingAlert = true
                        }
                        try await quickBook.quickBook(location: location, duration: duration, time: time)
                    }
                }
            } label: {
                Label(isEnabled ? "Book now" : "Find me a room", systemImage: "wand.and.sparkles")
                    .font(.body)
                    .foregroundStyle(isEnabled ? Color.white : Color.black)
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(isEnabled ? Color("gsrBlue") : Color.white)
                            .shadow(radius: 2)
                    }
            }
        }
        .onAppear {
            self.feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            
            let slots = vm.getRelevantAvailability()
            self.earliestTimeRequirement = slots.sorted(by: { $0.startTime < $1.startTime }).first?.startTime
            self.latestTimeRequirement = slots.sorted(by: { $0.endTime > $1.endTime }).first?.endTime
            
            guard let loc = vm.selectedLocation else { return }
            switch loc.kind {
            case .libcal, .penngroups:
                self.durationOptions = [30, 60, 90, 120]
                self.minTimeRequirement = 30
                self.maxTimeRequirement = 120
            case .wharton:
                self.durationOptions = [30, 60, 90]
                self.minTimeRequirement = 30
                self.maxTimeRequirement = 90
            }
        }
        .alert(quickBook.activeAlert?.title ?? "Booking Error", isPresented: Binding<Bool>(
            get: { quickBook.activeAlert != nil },
            set: { newValue in
                if !newValue { quickBook.activeAlert = nil }
            }
        ), presenting: quickBook.activeAlert) { alert in
            Button("OK") {
                alert.onAccept?()
                quickBook.activeAlert = nil
            }
            Button("Cancel", role: .cancel) {
                alert.onCancel?()
                quickBook.activeAlert = nil
            }
        } message: { alert in
            Text(alert.message).font(.subheadline)
        }
    }
}

