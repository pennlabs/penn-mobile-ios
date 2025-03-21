//
//  GSRBookingView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRBookingView: View {
    static var pickerOptions: [Date] = (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: Date.now.localTime) }
    static var locationOptions: [GSRLocation] = [GSRLocation(lid: "ASDF", gid: 123, name: "Weigle", kind: .libcal, imageUrl: "https://google.com")]
    
    @State var selectedLoc = GSRBookingView.locationOptions.first!
    @State var selectedDate = GSRBookingView.pickerOptions.first!
    var body: some View {
        VStack {
            Picker("Date", selection: $selectedDate) {
                ForEach(GSRBookingView.pickerOptions, id: \.self) { option in
                    Text(option.localizedGSRText)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Picker("Location", selection: $selectedLoc) {
                ForEach(GSRBookingView.locationOptions, id: \.self) { loc in
                    Text(loc.name)
                }
            }
            Spacer()
        }
            .navigationTitle("Choose a Time Slot")
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
}

#Preview {
    GSRBookingView()
}
