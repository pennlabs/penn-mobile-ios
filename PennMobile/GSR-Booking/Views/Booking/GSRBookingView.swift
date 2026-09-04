//
//  GSRBookingView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Lottie

extension EnvironmentValues {
    @Entry var gsrUnderlyingHorizontalProxy: ScrollProxyWrapper?
    @Entry var gsrUnderlyingVerticalProxy: ScrollProxyWrapper?
    @Entry var gsrScrollMode: GSRScrollMode = .vertical
}

enum GSRScrollMode: Int {
    case horizontal = 0
    case vertical = 1
}

struct GSRBookingView: View {
    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.presentToast) var presentToast
    @EnvironmentObject var nav: NavigationManager
    @Binding var centralTab: GSRTab
    @State var selectedLocInternal: GSRLocation
    @State var showSettings: Bool = false
    @State var settingsPopoverAttachmentPoint: CGPoint? = nil
    
    @State var horizScrollProxy: ScrollProxyWrapper?
    @State var vertScrollProxy: ScrollProxyWrapper?
    @State var scrollMode: GSRScrollMode = .vertical
    
    
    var body: some View {
        VStack {
            Picker("Location", selection: $selectedLocInternal) {
                ForEach(vm.availableLocations.standardGSRSort, id: \.self) { loc in
                    Text(loc.name)
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
            
            if !vm.isLoadingAvailability {
                if vm.hasAvailableBooking {
                    GSRTwoWayScrollView(vProxy: $vertScrollProxy, hProxy: $horizScrollProxy)
                        .environment(\.gsrScrollMode, self.scrollMode)
                        .overlay {
                            VStack {
                                Spacer()
                                GSRBookingToolbarView(scrollMode: $scrollMode)
                                    .environment(\.gsrUnderlyingHorizontalProxy, self.horizScrollProxy)
                                    .environment(\.gsrUnderlyingVerticalProxy, self.vertScrollProxy)
                                    .padding(24)
                            }
                        }
                } else {
                    VStack {
                        Spacer()
                        Image("EmptyStateGSR")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                        Text("No rooms available")
                            .font(.title2)
                            .fontWeight(.light)
                        Spacer()
                    }
                    
                    
                }
            } else {
                VStack(alignment: .center) {
                    Spacer()
                    LottieView {
                      try await DotLottieFile.named("gsr-loading")
                    }
                    .playing(loopMode: .autoReverse)
                    .frame(width: 250, height: 250)
                    Spacer()
                }
            }
            
            
        }
            .navigationTitle("Choose a Time Slot")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .accessibilityLabel("Settings")
                    }
                    .popover(isPresented: $showSettings, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                        VStack {
                            Toggle(isOn: $vm.settings.shouldShowFullyUnavailableRooms) {
                                Text("Show Unavailable Rooms")
                            }
                        }
                        .padding()
                        .presentationCompactAdaptation(.popover)
                    }
                }
            }
            .onChange(of: selectedLocInternal) { old, new in
                Task {
                    do {
                        try await vm.setLocation(to: new)
                    } catch {
                        presentToast(.init(message: "\(error.localizedDescription)"))
                        withAnimation {
                            selectedLocInternal = old
                        }
                    }
                }
            }
            .onChange(of: vm.selectedDate) {
                Task { @MainActor in
                    do {
                        try await vm.updateAvailability()
                    } catch {
                        presentToast(.init(message: "\(error.localizedDescription)"))
                    }
                }
            }
            .onAppear {
                Task {
                    do {
                        try await vm.setLocation(to: selectedLocInternal)
                    } catch {
                        presentToast(.init(message: "\(error.localizedDescription)"))
                    }
                }
            }
            .alert("Booking Successful", isPresented: $vm.showSuccessfulBookingAlert, presenting: vm.recentBooking) { _ in
                Button("Okay") {
                    vm.showSuccessfulBookingAlert = false
                    nav.path.removeLast()
                    
                }
                Button("View Booking") {
                    vm.showSuccessfulBookingAlert = false
                    nav.path.removeLast()
                    centralTab = .reservations
                }
            } message: { booking in
                Text("You've successfully made a reservation for \(booking.roomName)")
            }
    }
}

struct ScrollProxyWrapper: Equatable, Hashable {
    let id = UUID()
    let proxy: ScrollViewProxy
    
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(proxy: ScrollViewProxy) {
        self.proxy = proxy
    }
}
