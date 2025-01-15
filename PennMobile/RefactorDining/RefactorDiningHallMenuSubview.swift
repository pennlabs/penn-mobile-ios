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
            
        }
        .onAppear() {
            menuDate = Date.now.localTime
        }
        
        if let current = currentMeal {
            ForEach(current.stations) { station in
                Section(header: Text(station.name)) {
                    Text("\(station.items.count) items")
                }
            }
        }
    }
}
