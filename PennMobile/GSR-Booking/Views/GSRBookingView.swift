//
//  GSRBookingView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Lottie

struct GSRBookingView: View {
    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.presentToast) var presentToast
    @EnvironmentObject var nav: NavigationManager
    @State var selectedLocInternal: GSRLocation
    
    
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
                GSRTwoWayScrollView()
                    .overlay {
                        VStack {
                            Spacer()
                            GSRBookingToolbarView()
                                .padding(24)
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
            .onChange(of: selectedLocInternal) { old, new in
                Task {
                    do {
                        try await vm.setLocation(to: new)
                    } catch {
                        presentToast(ToastConfiguration({
                            Text(error.localizedDescription)
                        }))
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
                        presentToast(ToastConfiguration({
                            Text(error.localizedDescription)
                        }))
                    }
                }
            }
            .onAppear {
                Task {
                    do {
                        try await vm.setLocation(to: selectedLocInternal)
                    } catch {
                        presentToast(ToastConfiguration({
                            Text(error.localizedDescription)
                        }))
                    }
                }
            }
            .alert("Booking Successful", isPresented: $vm.showSuccessfulBookingAlert, presenting: vm.recentBooking) { _ in
                Button("Okay") {
                    vm.showSuccessfulBookingAlert = false
                    nav.path.removeLast()
                    
                }
                Button("View Booking") {}
            } message: { booking in
                Text("You've successfully made a reservation for \(booking.roomName)")
            }
    }
}
