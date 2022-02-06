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
            //Option 1: Just have the dining view header as an item in the list
            //DiningViewHeader()
            
            //Options 2 & 3: Put the Dining View header in a section with "Dining Balance" header
            Section(header: CustomHeader(name: "Dining Balance"), content: {
                
                //Option 2: Have DiningViewHeader() be the header of an empty section
                Section(header: DiningViewHeader(), content: {})
                
                //Option 3: Have DiningViewHeader() as content in the "Dining Balance" Section
                //DiningViewHeader()
            })
       
            ForEach(diningVM.ordering, id: \.self) { venueType in
                Section(header: CustomHeader(name: venueType.fullDisplayName)) {
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
    }
}

@available(iOS 14, *)
struct CustomHeader: View {

    let name: String

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 21, weight: .semibold))
            Spacer()
        }
        .padding()
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .background(Color(UIColor.uiBackground))
        //Default Text Case for Header is Caps Lock
        .textCase(nil)
    }
}

@available(iOS 14, *)
struct DiningVenueView_Previews: PreviewProvider {
    static var previews: some View {
        CustomHeader(name: "new")
    }
}
