//
//  DiningVenueDetailMenuView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 23/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI

struct DiningVenueDetailMenuView: View {
    var menus: [DiningMenu]
    var id: Int
    @State var menuDate = Date()
    @EnvironmentObject var diningVM: DiningViewModelSwiftUI

    var body: some View {
        DatePicker(selection: $menuDate, in: Date()...Date().addingTimeInterval(86400 * 6), displayedComponents: .date) {
            Text("Menu date")
        }.onChange(of: menuDate) { newMenuDate in
            diningVM.refreshMenu(for: id, at: newMenuDate)
        }
        VStack(alignment: .leading, spacing: 10) {
            Text("Penn has recently changed the process in which Penn Labs can access menu data. We are working as fast as possible to fix this. We apologize for the inconvenience.")
            Text("In the meantime, we have directly linked the menu below.")
        }
        //        ForEach(menus, id: \.self) { menu in
        //            DiningMenuRow(for: menu)
        //                .transition(.opacity)
        //        }
        Link(destination: URL(string: DiningVenue.menuUrlDict[id] ?? "https://university-of-pennsylvania.cafebonappetit.com/")!) {
            CardView {
                HStack {
                    Text("Menu")
                        .font(.system(size: 20, design: .rounded))
                        .bold()
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .foregroundColor(.blue).font(Font.system(size: 24).weight(.bold))
            }
        }
        .frame(height: 24)
        .padding([.top])
    }
}

struct DiningVenueDetailMenuView_Previews: PreviewProvider {
    let diningVenues: DiningMenuAPIResponse = Bundle.main.decode("mock_menu.json")

    static var previews: some View {
        return NavigationView {
            ScrollView {
                VStack {
                    DiningVenueDetailMenuView(menus: [], id: 1)
                    Spacer()
                }
            }.navigationTitle("Dining")
            .padding()
        }
    }
}
