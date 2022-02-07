//
//  DiningVenueView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 9/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI

@available(iOS 14, *)
struct DiningVenueView: View {
    @EnvironmentObject var diningVM: DiningViewModelSwiftUI
    
    // Hack to deselect cells after popping navigation view
    // Will be removed once SwiftUI is Fixed
    @State private var selectedItem: String?
    @State private var listViewId = UUID()
    
    var body: some View {
        List {
            Section(header: CustomHeader(name: "Dining Balance", refreshButton: true), content: {
                Section(header: DiningViewHeader(), content: {})
            })
       
            ForEach(diningVM.ordering, id: \.self) { venueType in
                Section(header: CustomHeader(name: venueType.fullDisplayName, refreshButton: false)) {
                    ForEach(diningVM.diningVenues[venueType] ?? []) { venue in
                        NavigationLink(destination: DiningVenueDetailView(for: venue).environmentObject(diningVM), tag: "\(venue.id)", selection: $selectedItem) {
                            DiningVenueRow(for: venue)
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .background(Color(UIColor.uiBackground))
        // Hack to deselect items
        .id(listViewId)
        .onAppear {
            diningVM.refreshVenues()
            diningVM.refreshBalance()
            if selectedItem != nil {
                selectedItem = nil
                listViewId = UUID()
            }
        }
        .listStyle(.plain)
    }
}

struct CustomHeader: View {

    let name: String
    let refreshButton: Bool

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 21, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
            if(refreshButton) {
                Button(action: {
                    print("Hi")
                }, label: {
                    Image(systemName: "arrow.counterclockwise")
                })
            }
        }
        .padding()
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .background(Color(UIColor.uiBackground))
        //Default Text Case for Header is Caps Lock
        .textCase(nil)
    }
}

struct DiningVenueView_Previews: PreviewProvider {
    static var previews: some View {
        CustomHeader(name: "new", refreshButton: false)
    }
}
