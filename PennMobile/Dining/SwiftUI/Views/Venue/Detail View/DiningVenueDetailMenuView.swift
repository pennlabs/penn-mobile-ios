//
//  DiningVenueDetailMenuView.swift
//  PennMobile
//
//  Created by Jon Melitski on 2/26/2024.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import WebKit
import PennMobileShared

struct DiningVenueDetailMenuView: View {
    
    @EnvironmentObject var diningVM: DiningViewModelSwiftUI
    
    var id: Int
    var venue: DiningVenue
    var parentScrollProxy: ScrollViewProxy
    
    /// Notable invariant, the menuDate must ALWAYS match all of the menus in the array.
    @State var menuDate: Date
    @State var menus: [DiningMenu]
    
    // Both are nil on init
    @State private var currentMenu: DiningMenu?
    @State private var selectedStation: DiningStation?
    
    @Binding private var parentScrollOffset: CGPoint
    
    init(menus: [DiningMenu], id: Int, venue: DiningVenue, menuDate: Date = Date().localTime, parentScrollProxy: ScrollViewProxy, parentScrollOffset: Binding<CGPoint>) {
        self.id = id
        self.venue = venue
        self.parentScrollProxy = parentScrollProxy
        _parentScrollOffset = parentScrollOffset
        _menus = State(initialValue: menus)
        _menuDate = State(initialValue: menuDate)
        _currentMenu = State(initialValue: getMenu())
        _selectedStation = State(initialValue: currentMenu?.stations.first ?? nil)
        
    }
    
    /// Constraints of this function:
    /// Need to know if a meal is currently going on, to return it.
    /// If there is a meal today that is closest (utilities), return it.
    /// If the selected date is not the current day, return the first menu.
    /// If at any point, the list of menus is empty, return nil.
    func getMenu() -> DiningMenu? {
        if (menus.count == 0) { return nil }
        
        if (!Calendar.current.isDate(menuDate, inSameDayAs: Date())) {
            return menus[0]
        }
        
        guard let nearestIndex = venue.currentOrNearestMealIndex else {
            return nil
        }
        
        return menus[nearestIndex]
    }
    
    var body: some View {
        LazyVStack(pinnedViews: [.sectionHeaders]) {
            HStack {
                if currentMenu != nil {
                    Picker("Menu", selection: Binding($currentMenu)!) {
                        ForEach(menus, id: \.self) { menu in
                            Text(menu.service)
                        }
                    }.pickerStyle(MenuPickerStyle())
                } else {
                    Text("Closed For Today")
                }
                DatePicker("", selection: $menuDate, in: Date().localTime...Date().localTime.add(minutes: 8640), displayedComponents: .date)
            }
            
            Section {
                DiningStationRowStack(selectedStation: $selectedStation, currentMenu: $currentMenu, parentScrollOffset: $parentScrollOffset, parentScrollProxy: parentScrollProxy)
                    
                    
            } header: {
                DiningMenuViewHeader(diningMenu: $currentMenu, selectedStation: $selectedStation)
            }
            
//            .onChange(of: parentScrollOffset) { _ in
//                print(proxy.size)
//            }
            
        }
        
        .onChange(of: currentMenu) { _ in
            print((currentMenu?.service ?? "no menu") + " on " + menuDate.description)
            selectedStation = currentMenu?.stations.first ?? nil
        }
        .onChange(of: menuDate) { newDate in
            Task.init() {
                await diningVM.refreshMenus(cache: false, at: newDate)
                menuDate = newDate
                menus = diningVM.diningMenus[venue.id]?.menus ?? []
                currentMenu = getMenu()
            }
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
