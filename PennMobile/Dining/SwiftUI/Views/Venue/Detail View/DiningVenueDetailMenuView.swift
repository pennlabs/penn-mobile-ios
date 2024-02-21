//
//  DiningVenueDetailMenuView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 23/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI
import WebKit
import PennMobileShared

struct DiningVenueDetailMenuView: View {
    var menus: [DiningMenu]
    var id: Int
    var venue: DiningVenue?
    var globalScrollProxy: ScrollViewProxy
    @State var menuDate: Date
    @State private var currentMenu: DiningMenu
    @State private var showMenu: Bool
    @State private var selectedStation: DiningStation?
    @EnvironmentObject var diningVM: DiningViewModelSwiftUI
    init(menus: [DiningMenu], id: Int, venue: DiningVenue? = nil, menuDate: Date = Date(), globalScrollProxy: ScrollViewProxy, showMenu: Bool = false) {
        self.menus = menus
        self.id = id
        self.venue = venue
        self.globalScrollProxy = globalScrollProxy
        _showMenu = State(initialValue: showMenu)
        _menuDate = State(initialValue: menuDate)
        _currentMenu = State(initialValue: menus[0])
        _currentMenu = State(initialValue: self.getMenu())
        _selectedStation = State(initialValue: currentMenu.stations.first ?? nil)
    }
    func getMenu() -> DiningMenu {
        var inx = 0
        if self.venue != nil && Calendar.current.isDate(self.menuDate, inSameDayAs: Date()) {
            if let meal = self.venue!.currentOrNearestMeal {
                inx = self.menus.firstIndex { $0.service == meal.label } ?? inx
            }
        }
        return menus[inx]
    }
    var body: some View {
        LazyVStack(pinnedViews: [.sectionHeaders]) {
            // Date Picker and Meal selector
            HStack {
                if menus.count > 0 {
                    Picker("Menu", selection: self.$currentMenu) {
                        ForEach(menus, id: \.self) { menu in
                            Text(menu.service)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                DatePicker(selection: $menuDate, in: Date()...Date().addingTimeInterval(86400 * 6), displayedComponents: .date) {
                }
                .onChange(of: menuDate) { newMenuDate in
                    currentMenu = menus[0]
                    
                    Task.init() {
                        await diningVM.refreshMenus(cache: false, at: newMenuDate)
                    }
                    if Calendar.current.isDate(newMenuDate, inSameDayAs: Date()) {
                        currentMenu = getMenu()
                    }
                }
            }
            Section {
                ForEach(currentMenu.stations, id: \.self) { station in
                    DiningStationRow(diningStation: station)
                        .bold(selectedStation != nil && selectedStation! == station)
                }
            } header: {
                DiningMenuViewHeader(diningMenu: $currentMenu, selectedStation: $selectedStation)
                    .onChange(of: currentMenu) { _ in
                        selectedStation = currentMenu.stations.first ?? nil
                    }
            }
        }.onChange(of: selectedStation) { _ in
            withAnimation {
                globalScrollProxy.scrollTo(selectedStation!, anchor: .top)
            }
        }
    }
}

//struct DiningVenueDetailMenuView_Previews: PreviewProvider {
//    let diningVenues: MenuList = Bundle.main.decode("mock_menu.json")
//
//    static var previews: some View {
//        return NavigationView {
//            ScrollView {
//                VStack {
//                    DiningVenueDetailMenuView(menus: [], id: 1)
//                    Spacer()
//                }
//            }.navigationTitle("Dining")
//            .padding()
//        }
//    }
//}

struct MenuWebView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}
