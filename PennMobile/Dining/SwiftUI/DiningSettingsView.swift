//
//  DiningSettingsView.swift
//  PennMobile
//
//  Created by Christina Qiu on 11/5/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct DiningSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var totalData = false
    @State private var selectedOptionIndex = 0
    private let options = ["Total data",
                               "Smart calculation",
                               "Weighted average"]
        
    var body: some View {
        NavigationView {
            Form {
                // Your settings view content here
                Picker(selection: $selectedOptionIndex, label: Text("Calculate Options")) {
                                    ForEach(0..<options.count, id: \.self) { index in
                                        Text(options[index]).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                
                Toggle("Include guest swipes", isOn: $totalData)
                
            }
            .navigationBarTitle("Dining Analytics Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

#Preview {
    DiningSettingsView()
}
