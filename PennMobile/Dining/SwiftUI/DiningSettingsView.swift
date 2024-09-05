//
//  DiningSettingsView.swift
//  PennMobile
//
//  Created by Christina Qiu on 11/5/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct DiningSettingsView: View {
    @ObservedObject var viewModel: DiningAnalyticsViewModel
    
    @Environment(\.presentationMode) var presentationMode
    @State private var totalData = false
    private let options = ["All data",
                           "Smart calculation",
                           "Weighted average"]
        
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationView {
                Form {
                    Picker(selection: $viewModel.selectedOptionIndex, label: Text("Slope Calculation")) {
                        ForEach(0..<options.count, id: \.self) { index in
                            Text(options[index]).tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Toggle("Remove Outliers (Beta)", isOn: $viewModel.shouldRemoveOutliers)
                    // Toggle("Include guest swipes", isOn: $totalData)
                }
                .navigationBarTitle("Dining Analytics Settings", displayMode: .inline)
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
            .presentationDetents([.medium])
        } else {
            NavigationView {
                Form {
                    Picker(selection: $viewModel.selectedOptionIndex, label: Text("Slope Calculation")) {
                        ForEach(0..<options.count, id: \.self) { index in
                            Text(options[index]).tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    Toggle("Remove Outliers (Beta)", isOn: $viewModel.shouldRemoveOutliers)
                    // Toggle("Include guest swipes", isOn: $totalData)
                }
                .navigationBarTitle("Dining Analytics Settings", displayMode: .inline)
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
}
