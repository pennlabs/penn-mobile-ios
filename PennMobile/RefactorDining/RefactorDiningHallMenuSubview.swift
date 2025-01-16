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
    
    var body: some View {
        HStack {
            if currentMeal != nil {
                Picker("Menu", selection: Binding($currentMeal)!) {
                    ForEach(mealsOnDate, id: \.self) { meal in
                        Text(meal.service)
                            .font(.system(.body, design: .serif))
                    }
                }.pickerStyle(MenuPickerStyle())
            } else {
                Text("Closed For Today")
                    .font(.system(.body, design: .serif))
            }
            Spacer()
            DatePicker("", selection: $menuDate, in: Date.currentLocalDate...Date.currentLocalDate.add(minutes: 8640), displayedComponents: .date)
                .font(.system(.body, design: .serif))
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
            ForEach(current.stations) { station in
                Section(header: RefactorDiningStationHeader(station: station)) {
                    RefactorDiningStationBody(station: station, focusedItem: $focusedItem)
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
                    .font(.system(.title, design: .serif))
                    .bold()
                    .padding(6)
                Spacer()
            }

        }
        .ignoresSafeArea()
        .background(.ultraThickMaterial)
        
        
        
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
                            .font(.system(.body, design: .serif))
                            .truncationMode(.tail)
                        // dietary icons
                        HStack(alignment: .center) {
                            RefactorDiningItemAllergenStack(item)
                            GeometryReader { geometry in
                                Path { path in
                                    path.move(to: CGPoint(x: 0, y: 0))
                                    path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                                }
                                .stroke(style: StrokeStyle(lineWidth: 0.5))
                                .foregroundColor(.primary)
                            }
                            .frame(height: 1)
                            if let cals = item.nutritionInfo["Calories"] {
                                Text("\(cals)cal")
                                    .font(.system(.body, design: .serif))
                            }
                        }
                    }
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
