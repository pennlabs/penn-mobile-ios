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
    @EnvironmentObject var vm: GSRViewModel
    @Binding var isEnabled: Bool
    @State var expectedWidth: CGFloat?
    @State var feedbackGenerator: UIImpactFeedbackGenerator? = nil
    @State var durationOptions: [Int] = []
    
    @State var minTimeRequirement: Int?
    @State var maxTimeRequirement: Int?
    @State var earliestTimeRequirement: Date?
    @State var latestTimeRequirement: Date?
            
    let formatter = DateFormatter()
    
    init(isEnabled: Binding<Bool>) {
        self._isEnabled = isEnabled
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
    }
    
    var body: some View {
        VStack {
            Spacer()
            if let expectedWidth, isEnabled {
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
                    RoundedRectangle(cornerRadius: 12).frame(width: expectedWidth, height: expectedWidth)
                }
                .frame(width: expectedWidth, height: expectedWidth)
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
                        let vc = QuickBookViewController()
                        do {
                            try await vc.populateSoonestTimeslot(location: location, duration: duration, time: time)
                        } catch {
                            print(error)
                            return
                        }
                        vc.onQuickBookSuccess = { booking in
                            vm.recentBooking = booking
                            Task {
                                vm.currentReservations = (try? await GSRNetworkManager.getReservations()) ?? []
                            }
                            vm.showSuccessfulBookingAlert = true
                        }
                        vc.quickBook()
                    }
                }
            } label: {
                Label("Find me a room", systemImage: "wand.and.sparkles")
                    .font(.body)
                    .foregroundStyle(isEnabled ? Color.white : Color.black)
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(isEnabled ? Color("gsrBlue") : Color.white)
                            .shadow(radius: 2)
                    }
            }
            .background {
                GeometryReader { ctx in
                    Color.clear
                        .onAppear {
                            expectedWidth = ctx.size.width
                        }
                        .onChange(of: ctx.size.width) {
                            expectedWidth = ctx.size.width
                        }
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
            case .libcal:
                self.durationOptions = [30, 60, 90, 120]
                self.minTimeRequirement = 30
                self.maxTimeRequirement = 120
            case .wharton:
                self.durationOptions = [30, 60, 90]
                self.minTimeRequirement = 30
                self.maxTimeRequirement = 90
            }
        }
    }
}

