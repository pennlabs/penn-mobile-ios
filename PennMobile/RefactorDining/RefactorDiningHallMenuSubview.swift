//
//  RefactorDiningHallMenuSubview.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/14/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI



struct RefactorDiningHallMenuSubview: View {
    @ObservedObject private var vm: ViewModel
    @State private var headerOffset: CGFloat = 0
    
    class ViewModel: ObservableObject {
        let hall: RefactorDiningHall
        @Published var currentMeal: RefactorDiningMeal?
        @Published var menuDate: Date = Date.distantPast {
            didSet {
                let newMeals = hall.meals.filter({
                    Calendar.current.isDate(menuDate.localTime, equalTo: $0.startTime.localTime, toGranularity: .day)
                })
                mealsOnDate = newMeals
                if let meal = hall.currentStatus().relevantMeal, mealsOnDate.contains(meal) {
                    currentMeal = meal
                } else {
                    currentMeal = newMeals.first
                }
            }
        }
        @Published var mealsOnDate: [RefactorDiningMeal] = []
        @Published var focusedItem: RefactorDiningItem? = nil
        @Published var focusedStationId: UUID? = nil {
            willSet {
                
                // if it's more than one station away from the current ID, don't animate scrolling
                if newValue != focusedStationId {
                    print("hello")
                }
            }
        }
        
        init(hall: RefactorDiningHall) {
            self.hall = hall
        }
        
        func setFocusedStation(_ station: RefactorDiningStation?) {
            self.focusedStationId = station?.id ?? nil
        }
        
        func setFocusedItem(_ item: RefactorDiningItem?) {
            self.focusedItem = item
        }
        
        
    }
    
    init(hall: RefactorDiningHall) {
        vm = ViewModel(hall: hall)
    }
    
    var body: some View {
        HStack {
            if vm.currentMeal != nil {
                Picker("Menu", selection: Binding($vm.currentMeal)!) {
                    ForEach(vm.mealsOnDate, id: \.self) { meal in
                        Text(meal.service)
                    }
                }.pickerStyle(MenuPickerStyle())
            } else {
                Text("Closed For Today")
            }
            Spacer()
            DatePicker("", selection: $vm.menuDate, in: Date.currentLocalDate...Date.currentLocalDate.add(minutes: 8640), displayedComponents: .date)
                .padding()
            
        }
        .onAppear() {
            vm.menuDate = Date.now.localTime
        }
        
        if let current = vm.currentMeal {
            ScrollViewReader { proxy in
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section(header: GeometryReader { headerGeo in
                        VStack {
                            RefactorDiningHallMenuHeader(meal: current)
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
                            return RefactorDiningStation.getWeight(station: el1) < RefactorDiningStation.getWeight(station: el2)
                        })
                        
                        
                        ForEach(sorted.indices, id: \.self) { index in
                            Group {
                                RefactorDiningStationHeader(station: sorted[index])
                                RefactorDiningStationBody(station: sorted[index])
                            }
                            .environmentObject(vm)
                            .id(sorted[index].idVert)
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
    let meal: RefactorDiningMeal
    let sortedStations: [RefactorDiningStation]
    @EnvironmentObject var vm: RefactorDiningHallMenuSubview.ViewModel
    
    init(meal: RefactorDiningMeal) {
        self.meal = meal
        self.sortedStations = meal.stations.sorted { el1, el2 in
            return RefactorDiningStation.getWeight(station: el1) < RefactorDiningStation.getWeight(station: el2)
        }
    }
    
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 20) {
                    ForEach(sortedStations, id: \.idHoriz) { station in
                        Text(station.name.uppercased())
                            .font(.headline)
                            .bold(station.id == vm.focusedStationId)
                            .underline(station.id == vm.focusedStationId)
                            
                    }
                }
            }
            .padding(.horizontal)
            .onChange(of: vm.focusedStationId) { new in
                guard let station = sortedStations.filter({ el in
                    return el.id == new
                }).first else {
                    return
                }
                withAnimation {
                    proxy.scrollTo(station.idHoriz, anchor: .leading)
                }
            }
        }
    }
}


struct RefactorDiningStationHeader: View {
    let station: RefactorDiningStation

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
    let station: RefactorDiningStation
    let items: [RefactorDiningItem]
    @EnvironmentObject var vm: RefactorDiningHallMenuSubview.ViewModel
    
    
    init(station: RefactorDiningStation) {
        self.station = station
        self.items = station.items.sorted { el1, el2 in
//            if let el1ServingString = el1.nutritionInfo["Serving Size"],
//               let el2ServingString = el2.nutritionInfo["Serving Size"],
//               let el1ServingSize: Double = Double(el1ServingString.replacingOccurrences(of: "oz", with: "")),
//               let el2ServingSize: Double = Double(el2ServingString.replacingOccurrences(of: "oz", with: "")) {
//                
//                return el1ServingSize < el2ServingSize
//            }
            
            return el1.itemId > el2.itemId
            
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(items) { item in
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        
                        Text(NSString(string: item.name).localizedCapitalized)
                            .bold()
                            .truncationMode(.tail)
                        // dietary icons
                        HStack(alignment: .center, spacing: 4) {
                            RefactorDiningItemAllergenStack(item)
                            
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
                .padding(.horizontal)
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
