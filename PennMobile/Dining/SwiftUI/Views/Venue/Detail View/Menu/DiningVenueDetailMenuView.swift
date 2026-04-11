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
        if let relevantMeal = venue.currentStatus().relevantMeal,
           let meal = menus.matchMenu(with: relevantMeal),
           Calendar.current.isDate(relevantMeal.starttime, inSameDayAs: menuDate) {
            return meal
        } else {
            return venue.mealsOnDate(menuDate).compactMap({ menus.matchMenu(with: $0) }).first
        }
    }
    
    var body: some View {
        LazyVStack(pinnedViews: [.sectionHeaders]) {
            HStack {
                if let currentMenu {
                    let boundMenu = Binding { currentMenu } set: { new in
                        withAnimation {
                            self.currentMenu = new
                        }
                    }
                    Picker("Menu", selection: boundMenu) {
                        ForEach(menus.sorted(by: { $0.startTime < $1.endTime }), id: \.self) { menu in
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
            Task {
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
