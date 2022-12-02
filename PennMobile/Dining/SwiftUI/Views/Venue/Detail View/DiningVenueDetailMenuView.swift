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
    @State var menuDate: Date
    @State private var menuIndex: Int
    @State private var showMenu: Bool
    @EnvironmentObject var diningVM: DiningViewModelSwiftUI
    init(menus: [DiningMenu], id: Int, venue: DiningVenue? = nil, menuDate: Date = Date(), showMenu: Bool = false) {
        self.menus = menus
        self.id = id
        self.venue = venue
        _showMenu = State(initialValue: showMenu)
        _menuDate = State(initialValue: menuDate)
        _menuIndex = State(initialValue: 0)
        _menuIndex = State(initialValue: self.getIndex())
    }
    func getIndex() -> Int {
        var inx = 0
        if self.venue != nil && Calendar.current.isDate(self.menuDate, inSameDayAs: Date()) {
            if let meal = self.venue!.currentOrNearestMeal {
                inx = self.menus.firstIndex { $0.service == meal.label } ?? inx
            }
        }
        return inx
    }

    var body: some View {
        DatePicker(selection: $menuDate, in: Date()...Date().addingTimeInterval(86400 * 6), displayedComponents: .date) {
            Text("Menu date")
        }.onChange(of: menuDate) { newMenuDate in
            menuIndex = 0
            Task.init() {
                await diningVM.refreshMenus(cache: false, at: newMenuDate)
            }
            if Calendar.current.isDate(newMenuDate, inSameDayAs: Date()) {
                menuIndex = getIndex()
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
            if menus.count > 0 {
                Picker("Menu", selection: self.$menuIndex) {
                    ForEach(0 ..< menus.count, id: \.self) {
                        Text(menus[$0].service)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                DiningMenuRow(diningMenu: menus[menuIndex])
                    .transition(.opacity)
            }
        }
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
