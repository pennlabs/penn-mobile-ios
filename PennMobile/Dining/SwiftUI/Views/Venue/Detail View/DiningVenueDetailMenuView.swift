//
//  DiningVenueDetailMenuView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 23/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI
import WebKit

struct DiningVenueDetailMenuView: View {
    var menus: [DiningMenu]
    var id: Int
    var venue: DiningVenue?
    @State var menuDate = Date()
    @State private var showMenu = false
    @EnvironmentObject var diningVM: DiningViewModelSwiftUI

    var body: some View {
        DatePicker(selection: $menuDate, in: Date()...Date().addingTimeInterval(86400 * 6), displayedComponents: .date) {
            Text("Menu date")
        }.onChange(of: menuDate) { newMenuDate in
            Task.init() {
                await diningVM.refreshMenus(cache: false, at: newMenuDate)
            }
        }
        VStack {
            Button {
                showMenu.toggle()
            } label: {
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
                .frame(height: 24)
                .padding([.top, .bottom])
            }
            .sheet(isPresented: $showMenu) {
                MenuWebView(url: URL(string: DiningVenue.menuUrlDict[id] ?? "https://university-of-pennsylvania.cafebonappetit.com/")!)
            }
            ForEach(menus, id: \.self) { menu in
                DiningMenuRow(diningMenu: menu, isExpanded: isOpen(menuType: menu.service))
                    .transition(.opacity)
            } // if change from no menu to has menu, doesn't switch
            // or if error happens, need to refresh menu on load also
        }
    }
    func isOpen(menuType: String) -> Bool {
        if venue == nil {
            return false
        }
        print("Venue: " + venue!.name)
        print("Type: " + menuType)
        if !Calendar.current.isDate(menuDate, inSameDayAs: Date()) {
            return false
        }
        guard let meal = venue!.currentOrNearestMeal else { return false }
        print(meal.label)
        return meal.label == menuType
    }
}

struct DiningVenueDetailMenuView_Previews: PreviewProvider {
    let diningVenues: MenuList = Bundle.main.decode("mock_menu.json")

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

struct MenuWebView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}
