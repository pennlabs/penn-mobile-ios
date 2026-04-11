//
//  RefactorDiningHallMenuSubview.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/14/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared



struct RefactorDiningHallMenuSubview: View {
    @ObservedObject private var diningVM = DiningViewModelSwiftUI.instance
    @StateObject private var vm: ViewModel
    @State private var headerOffset: CGFloat = 0
    
    class ViewModel: ObservableObject {
        let venue: DiningVenue
        
        @Published var currentMenu: DiningMenu?
        
        @Published private(set) var menuDate: Date
        @Published private(set) var menus: [DiningMenu]
        
        @Published var focusedItem: DiningStationItem? = nil
        @Published var focusedStation: DiningStation? = nil {
            willSet {
                // if it's more than one station away from the current ID, don't animate scrolling
//                if newValue != focusedStation {
//                    print("hello")
//                }
            }
        }
        
        @MainActor init(venue: DiningVenue) {
            self.venue = venue
            self.menuDate = Date.now
            self.menus = DiningViewModelSwiftUI.instance.diningMenus[venue.id]?.menus ?? []
            self.setMenuDay(date: Date.now)
        }
        
        func getStartingMenu() -> DiningMenu? {
            if let relevantMeal = venue.currentStatus().relevantMeal,
               let meal = menus.matchMenu(with: relevantMeal),
               Calendar.current.isDate(relevantMeal.starttime, inSameDayAs: menuDate) {
                return meal
            } else {
                return venue.mealsOnDate(menuDate).compactMap({ menus.matchMenu(with: $0) }).first
            }
        }
        
        func setMenuDay(date: Date) {
            self.menuDate = date
            Task { @MainActor in
                await DiningViewModelSwiftUI.instance.refreshMenus(cache: true, at: date)
                self.menus = DiningViewModelSwiftUI.instance.diningMenus[venue.id]?.menus ?? []
                self.currentMenu = getStartingMenu()
            }
        }
        
        func setFocusedStation(_ station: DiningStation?) {
            self.focusedStation = station
        }
        
        func setFocusedItem(_ item: DiningStationItem?) {
            self.focusedItem = item
        }
        
        
    }
    
    init(venue: DiningVenue) {
        self._vm = StateObject(wrappedValue: ViewModel(venue: venue))
    }
    
    var body: some View {
        let boundDate = Binding {
            vm.menuDate
        } set: { newDate in
            vm.setMenuDay(date: newDate)
        }
        HStack {
            if let current = vm.currentMenu {
                let boundMenu = Binding {
                    current
                } set: { new in
                    withAnimation {
                        self.vm.currentMenu = new
                    }
                }
                Picker("Menu", selection: boundMenu) {
                    ForEach(vm.menus.sorted(by: { $0.startTime < $1.startTime }), id: \.self) { meal in
                        Text(meal.service)
                    }
                }.pickerStyle(MenuPickerStyle())
            } else {
                Text("Closed For Today")
            }
            Spacer()
            DatePicker("", selection: boundDate, in: Date.currentLocalDate...Date.currentLocalDate.add(minutes: 8640), displayedComponents: .date)
                .foregroundStyle(Color("componentForeground"))
                .padding()
            
        }
        
        if let current = vm.currentMenu {
            ScrollViewReader { proxy in
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section(header: GeometryReader { headerGeo in
                        VStack {
                            RefactorDiningHallMenuHeader(menu: current)
                                .environmentObject(vm)
                                .onAppear {
                                    headerOffset = headerGeo.frame(in: .global).minY
                                }
                                .onChange(of: headerGeo.frame(in: .global).minY) { newValue in
                                    headerOffset = newValue
                                }
                                .frame(height: 50)
                                
                            Divider()
                        }
                        .background(.background)
                    }, content: {
                        let sorted = current.stations.sorted(by: { el1, el2 in
                            return DiningStation.getWeight(station: el1) < DiningStation.getWeight(station: el2)
                        })
                        
                        
                        ForEach(sorted.indices, id: \.self) { index in
                            Group {
                                RefactorDiningStationHeader(station: sorted[index])
                                RefactorDiningStationBody(station: sorted[index])
                            }
                            .padding(.horizontal)
                            .environmentObject(vm)
                            .id(sorted[index].vertUID)
                            .background {
                                GeometryReader { sectionGeo in
                                    let sectionTop = sectionGeo.frame(in: .global).minY
                                    let sectionBottom = sectionGeo.frame(in: .global).maxY
                                    
                                    let isIntersecting = (sectionTop <= headerOffset + 50 && sectionBottom >= headerOffset + 50)
                                    
                                    Color.clear
                                    .onAppear {
                                        if isIntersecting {
                                            vm.setFocusedStation(sorted[index])
                                        }
                                    }
                                    .onChange(of: sectionTop) { _ in
                                        if isIntersecting {
                                            vm.setFocusedStation(sorted[index])
                                        }
                                    }
                                }
                            }
                        }
                    })
                }
            }
        }
    }
}


struct RefactorDiningHallMenuHeader: View {
    let menu: DiningMenu
    let sortedStations: [DiningStation]
    @EnvironmentObject var vm: RefactorDiningHallMenuSubview.ViewModel
    
    init(menu: DiningMenu) {
        self.menu = menu
        self.sortedStations = menu.stations.sorted { el1, el2 in
            return DiningStation.getWeight(station: el1) < DiningStation.getWeight(station: el2)
        }
    }
    
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 20) {
                    ForEach(sortedStations, id: \.horizUID) { station in
                        Text(station.name.uppercased())
                            .font(.headline)
                            .bold(station == vm.focusedStation)
                            .underline(station == vm.focusedStation)
                            
                    }
                }
            }
            .padding(.horizontal)
            .onChange(of: vm.focusedStation) {
                guard let station = sortedStations.filter({ el in
                    return el == vm.focusedStation
                }).first else {
                    return
                }
                withAnimation {
                    proxy.scrollTo(station.horizUID, anchor: .leading)
                }
            }
        }
    }
}


struct RefactorDiningStationHeader: View {
    let station: DiningStation

    var body: some View {
        VStack {
            HStack {
                Text(NSString(string: station.name).localizedCapitalized)
                    .font(.title)
                    .bold()
                Spacer()
            }
        }
    }
}

struct RefactorDiningStationBody: View {
    let station: DiningStation
    let items: [DiningStationItem]
    @EnvironmentObject var vm: RefactorDiningHallMenuSubview.ViewModel
    
    
    init(station: DiningStation) {
        self.station = station
        self.items = station.items.sorted { el1, el2 in
//            if let el1ServingString = el1.nutritionInfo["Serving Size"],
//               let el2ServingString = el2.nutritionInfo["Serving Size"],
//               let el1ServingSize: Double = Double(el1ServingString.replacingOccurrences(of: "oz", with: "")),
//               let el2ServingSize: Double = Double(el2ServingString.replacingOccurrences(of: "oz", with: "")) {
//                
//                return el1ServingSize < el2ServingSize
//            }
            
            return el1.itemId < el2.itemId
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(items) { item in
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 2) {
                            
                            Text(NSString(string: item.name).localizedCapitalized)
                                .bold()
                                .truncationMode(.tail)
                            // dietary icons
                            HStack(alignment: .center, spacing: 4) {
                                DiningItemAllergenStack(item)
                                
                                if let cals = item.nutritionInfo["Calories"] {
                                    if (!item.getAllergenImages().isEmpty) {
                                        Text("•")
                                    }
                                    
                                    Text("\(cals)cal")
                                }
                                
                                
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(Angle(degrees: vm.focusedItem == item ? 90 : 0))
                    }
                    
                    if vm.focusedItem == item {
                        NutritionLabelView(item: item)
                            .contentTransition(.interpolate)
                    }
                    
                }
                .onTapGesture {
                    withAnimation {
                        vm.setFocusedItem(vm.focusedItem == item ? nil : item)
                    }
                }
            }
        }
        .padding(.vertical)
    }
}

struct NutritionLabelView: View {
    let item: DiningStationItem
    
    var body: some View {
        let nutritionData = item.nutritionInfo
        VStack {
            if !item.description.isEmpty {
                Text("\"\(item.description)\"")
                    .italic()
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            // Don't show the label if there is no calories given
            // Since calories are the first piece of information given generally
            if let cals = item.nutritionInfo["Calories"], cals != "" {
                VStack(alignment: .leading, spacing: 4) {
                    // Header
                    Text("Nutrition Facts")
                        .font(.system(size: 24, weight: .heavy))
                        .padding(.bottom, 4)
                    
                    // Serving Size & Calories Row
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Serving Size")
                                .font(.caption)
                            Text(nutritionData["Serving Size"] ?? "")
                                .font(.caption)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Calories")
                                .font(.caption)
                            Text(nutritionData["Calories"] ?? "")
                                .font(.title)
                                .fontWeight(.black)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Divider line similar to the label's rule
                    Divider()
                        .background(Color.black)
                        .padding(.vertical, 2)
                    
                    // Nutrient details
                    VStack(spacing: 2) {
                        nutrientRow(title: "Total Fat", value: nutritionData["Total Fat"] ?? "")
                        nutrientRow(title: "Saturated Fat", value: nutritionData["Saturated Fat"] ?? "")
                        nutrientRow(title: "Trans Fat", value: nutritionData["Trans Fat"] ?? "")
                        nutrientRow(title: "Cholesterol", value: nutritionData["Cholesterol"] ?? "")
                        nutrientRow(title: "Sodium", value: nutritionData["Sodium"] ?? "")
                        nutrientRow(title: "Total Carbohydrate", value: nutritionData["Total Carbohydrate"] ?? "")
                        nutrientRow(title: "Dietary Fiber", value: nutritionData["Dietary Fiber"] ?? "")
                        nutrientRow(title: "Sugars", value: nutritionData["Sugars"] ?? "")
                        nutrientRow(title: "Protein", value: nutritionData["Protein"] ?? "")
                    }
                    
                    
                }
                .padding(8)
                // Mimic the bordered label look
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.black, lineWidth: 2)
                )
            }
            if item.ingredients != "" {
                // Ingredients Section
                HStack {
                    VStack(alignment: .leading) {
                        Text("Ingredients: \(item.ingredients)")
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                        
                    }
                    Spacer()
                }
            }
        }
        .padding()
            
        
    }
    
    /// A helper function to build each nutrient row.
    @ViewBuilder private func nutrientRow(title: String, value: String) -> some View {
        if value != "" {
            HStack {
                Text(title)
                    .font(.footnote)
                Spacer()
                Text(value)
                    .font(.footnote)
            }
        }
    }
}
