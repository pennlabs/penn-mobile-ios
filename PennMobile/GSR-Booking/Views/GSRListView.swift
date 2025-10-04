//
//  GSRListView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 10/3/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRListView: View {
    @EnvironmentObject var vm: GSRViewModel
    @Binding var selectedTab: GSRTab
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if let first = vm.availableLocations.standardGSRSort.first {
                NavigationLink(value: first) {
                    GSRLocationCell(location: first)
                }
                .buttonStyle(PlainButtonStyle())
            }
            if vm.availableLocations.standardGSRSort.count > 1 {
                ForEach(vm.availableLocations.standardGSRSort.suffix(from: 1), id: \.self) { location in
                    Divider()
                    NavigationLink(value: location) {
                        GSRLocationCell(location: location)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal)
        .navigationDestination(for: GSRLocation.self) { loc in
            GSRBookingView(centralTab: $selectedTab, selectedLocInternal: loc)
                .frame(width: UIScreen.main.bounds.width)
                .environmentObject(vm)
        }
        .transition(.blurReplace)
    }
}
