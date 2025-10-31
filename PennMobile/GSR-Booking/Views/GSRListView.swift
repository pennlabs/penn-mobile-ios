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
            VStack(spacing: 0) {
                if vm.availableLocations.standardGSRSort.count > 1 {
                    ForEach(vm.availableLocations.standardGSRSort.indices, id: \.self) { index in
                        let location = vm.availableLocations.standardGSRSort[index]
                        if (index >= 1) { // no divider on first cell
                            Divider()
                        }
                        NavigationLink(value: location) {
                            GSRLocationCell(location: location)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                else {
                    ProgressView()
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 60)
        }
        .navigationDestination(for: GSRLocation.self) { loc in
            GSRBookingView(centralTab: $selectedTab, selectedLocInternal: loc)
                .frame(width: UIScreen.main.bounds.width)
                .environmentObject(vm)
        }
        .transition(.blurReplace)
    }
}
