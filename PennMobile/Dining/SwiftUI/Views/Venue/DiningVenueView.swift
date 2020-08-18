//
//  DiningVenueView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 9/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13, *)
struct DiningVenueView: View {
    @EnvironmentObject var diningVM: DiningViewModelSwiftUI
    
    var body: some View {
        
        List {
            ForEach(diningVM.ordering, id: \.self) { venueType in
                Section(header: CustomHeader(name: self.diningVM.getHeaderTitle(type: venueType))) {
                    ForEach(self.diningVM.diningVenues[venueType] ?? []) { venue in
                        NavigationLink(destination: DiningVenueDetailView(for: venue)) {
                            DiningVenueRow(for: venue)
                                .padding(.top, 6)
                                .padding(.bottom, 6)
                        }
                    }
                }
            }
        }
        .onAppear(perform: {
            DiningViewModelSwiftUI.instance.refreshVenues()
        })
    }
}

@available(iOS 13, *)
struct CustomHeader: View {

    let name: String

    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Text(name)
                    .font(.system(size: 21, weight: .semibold, design: .default))
                    .padding(.leading)
                Spacer()
            }

            Spacer()
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .background(Color(UIColor.uiBackground))
    }
}

@available(iOS 13, *)
struct DiningVenueView_Previews: PreviewProvider {
    static var previews: some View {
        DiningVenueView()
    }
}
