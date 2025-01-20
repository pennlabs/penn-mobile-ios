//
//  RefactorDiningHallMenuSubview.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/14/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI


struct RefactorDiningHallMenuSubview: View {
    let hall: RefactorDiningHall
    @State var currentMeal: RefactorDiningMeal?
    @State var menuDate: Date = Date.distantPast
    @State var mealsOnDate: [RefactorDiningMeal] = []
    @State var focusedItem: RefactorDiningItem? = nil
    
    @State private var headerOffset: CGFloat = 0
    @State private var focusedStationId: UUID? = nil
    
    var body: some View {
        HStack {
            if currentMeal != nil {
                Picker("Menu", selection: Binding($currentMeal)!) {
                    ForEach(mealsOnDate, id: \.self) { meal in
                        Text(meal.service)
                    }
                }.pickerStyle(MenuPickerStyle())
            } else {
                Text("Closed For Today")
            }
            Spacer()
            DatePicker("", selection: $menuDate, in: Date.currentLocalDate...Date.currentLocalDate.add(minutes: 8640), displayedComponents: .date)
                .onChange(of: menuDate) { newValue in
                    let newMeals = hall.meals.filter({
                        Calendar.current.isDate(newValue.localTime, equalTo: $0.startTime.localTime, toGranularity: .day)
                    })
                    mealsOnDate = newMeals
                    if let meal = hall.currentStatus().relevantMeal, mealsOnDate.contains(meal) {
                        currentMeal = meal
                    } else {
                        currentMeal = newMeals.first
                    }
                    
                }
                .padding()
            
        }
        .onAppear() {
            menuDate = Date.now.localTime
        }
        
        if let current = currentMeal {
            ScrollViewReader { proxy in
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section(header: GeometryReader { headerGeo in
                        RefactorDiningHallMenuHeader(meal: current, focusedStationId: $focusedStationId)
                            .onAppear {
                                headerOffset = headerGeo.frame(in: .global).minY
                            }
                            .onChange(of: headerGeo.frame(in: .global).minY) { newValue in
                                headerOffset = newValue
                            }
                            .frame(height: 50)
                    }, content: {
                        let sorted = current.stations.sorted(by: { el1, el2 in
                            return RefactorDiningStation.getWeight(station: el1) < RefactorDiningStation.getWeight(station: el2)
                        })
                        
                        
                        ForEach(sorted.indices, id: \.self) { index in
                            Group {
                                RefactorDiningStationHeader(station: sorted[index])
                                RefactorDiningStationBody(station: sorted[index], focusedItem: $focusedItem)
                            }
                            .id(sorted[index].idVert)
                            .background {
                                GeometryReader { sectionGeo in
                                    let sectionTop = sectionGeo.frame(in: .global).minY
                                    let sectionBottom = sectionGeo.frame(in: .global).maxY
                                    
                                    let isIntersecting = (sectionTop <= headerOffset + 50 && sectionBottom >= headerOffset + 50)
                                    
                                    Color.clear
                                    .onAppear {
                                        if isIntersecting {
                                            focusedStationId = sorted[index].id
                                        }
                                    }
                                    .onChange(of: sectionTop) { _ in
                                        if isIntersecting {
                                            focusedStationId = sorted[index].id
                                        }
                                    }
                                    .onChange(of: sectionBottom) { _ in
                                        if isIntersecting {
                                            focusedStationId = sorted[index].id
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
    @Binding var focusedStationId: UUID?
    let meal: RefactorDiningMeal
    let sortedStations: [RefactorDiningStation]
    
    init(meal: RefactorDiningMeal, focusedStationId: Binding<UUID?>) {
        self.meal = meal
        _focusedStationId = focusedStationId
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
                            .bold(station.id == focusedStationId)
                            
                    }
                }
                .background(.background)
            }
            .padding(.horizontal)
            .onChange(of: focusedStationId) { new in
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
    @Binding var focusedItem: RefactorDiningItem?
    
    
    init(station: RefactorDiningStation, focusedItem: Binding<RefactorDiningItem?>) {
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
        self._focusedItem = focusedItem
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
                        .rotationEffect(Angle(degrees: focusedItem == item ? 90 : 0))
                }
                .padding(.horizontal)
                .onTapGesture {
                    withAnimation {
                        focusedItem = (focusedItem == item) ? nil : item
                    }
                }
            }
        }
        .padding(.vertical)
    }
}
