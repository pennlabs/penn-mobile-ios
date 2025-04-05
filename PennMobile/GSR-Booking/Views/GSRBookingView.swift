//
//  GSRBookingView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRBookingView: View {
    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.presentToast) var presentToast
    @State var selectedLocInternal: GSRLocation
    
    
    var body: some View {
        VStack {
            Picker("Location", selection: $selectedLocInternal) {
                ForEach(vm.availableLocations, id: \.self) { loc in
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
            GSRTwoWayScrollView()
            Spacer()
            GSRBookingToolbarView() 
            
            
        }
            .navigationTitle("Choose a Time Slot")
            .onChange(of: selectedLocInternal) { old, new in
                do {
                    try vm.setLocation(to: new)
                } catch {
                    presentToast(ToastConfiguration({
                        Text(error.localizedDescription)
                    }))
                    withAnimation {
                        selectedLocInternal = old
                    }
                }
            }
            .onAppear {
                do {
                    try vm.setLocation(to: selectedLocInternal)
                } catch {
                    presentToast(ToastConfiguration({
                        Text(error.localizedDescription)
                    }))
                }
            }
    }
}

extension Date {
    var localizedGSRText: String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        }
        
        let weekday = Calendar.current.component(.weekday, from: self)
        let abbreviations = [
            1: "S", // Sunday
            2: "M", // Monday
            3: "T", // Tuesday
            4: "W", // Wednesday
            5: "R", // Thursday
            6: "F", // Friday
            7: "S"  // Saturday
        ]
            
        return abbreviations[weekday] ?? ""
    }
    
    var floorHalfHour: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        
        var roundedMinutes = (components.minute! / 30) * 30
        
        return calendar.date(bySettingHour: components.hour!, minute: roundedMinutes, second: 0, of: self)!
    }
}
