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
    
    init(menus: [DiningMenu], id: Int, venue: DiningVenue, menuDate: Date = Date.currentLocalDate, parentScrollProxy: ScrollViewProxy, parentScrollOffset: Binding<CGPoint>) {
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
        if menus.isEmpty {
            return nil
        }
        
        if !Calendar.current.isDate(menuDate, inSameDayAs: Date()) {
            return menus[0]
        }
        
        if let label = venue.currentMealType {
            // Attempt to find a menu with an exact match for the current meal
            if let menu = menus.first(where: { $0.service == label }) {
                return menu
            }
            
            // Attempt to find a menu for a "light" version of a meal
            // swiftlint:disable <no_space_in_method_call>
            let regex = /Light (.*)/
            if let match = try? regex.wholeMatch(in: label), let menu = menus.first(where: { $0.service == match.1 }) {
                return menu
            }
        }
        
        guard let nearestIndex = venue.currentOrNearestMealIndex, nearestIndex < menus.endIndex else {
            return nil
        }
        
        return menus[nearestIndex]
    }
    
    var body: some View {
        LazyVStack(pinnedViews: [.sectionHeaders]) {
            HStack {
                if currentMenu != nil {
                    Picker("Menu", selection: $currentMenu) {
                        ForEach(menus, id: \.self) { menu in
                            Text(menu.service)
                                .tag(menu)
                        }
                    }.pickerStyle(MenuPickerStyle())
                } else {
                    Text("No Menu Data")
                }
                DatePicker("", selection: $menuDate, in: Date.currentLocalDate...Date.currentLocalDate.add(minutes: 8640), displayedComponents: .date)
                
            }
            .padding(.horizontal)
            
            Section {
                DiningStationRowStack(selectedStation: $selectedStation, currentMenu: $currentMenu, parentScrollOffset: $parentScrollOffset, parentScrollProxy: parentScrollProxy)
                    .padding(.horizontal)
            } header: {
                VStack {
                    DiningMenuViewHeader(diningMenu: $currentMenu, selectedStation: $selectedStation)
                }
            }
        }
        .onChange(of: menuDate) {
            Task.init() {
                await diningVM.refreshMenus(cache: true, at: menuDate)
                menus = diningVM.diningMenus[venue.id]?.menus ?? []
                currentMenu = getMenu()
            }
        }
        
        .onChange(of: currentMenu) {
            print((currentMenu?.service ?? "no menu") + " on " + menuDate.description)
            selectedStation = nil
        }
        
    }
}
