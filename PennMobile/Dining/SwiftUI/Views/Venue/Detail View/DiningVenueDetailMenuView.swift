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

        ForEach(menus, id: \.self) { menu in
            DiningMenuRow(for: menu)
                .transition(.opacity)
        }
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
