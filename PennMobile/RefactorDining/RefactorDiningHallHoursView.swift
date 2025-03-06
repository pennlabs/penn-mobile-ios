//
//  RefactorDiningHallHoursView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct RefactorDiningHallHoursView: View {
    let hall: RefactorDiningHall
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(0..<7, id: \.self) { i in
                HStack {
                    VStack(alignment: .leading) {
                        let date = Calendar.current.date(byAdding: .day, value: i, to: Date.now)!
                        Text(date.formatted(date: .numeric, time: .omitted))
                            .font(.title2)
                            .bold()
                        if !hall.mealsOnDate(date).isEmpty {
                            RefactorDiningHallHoursStack(hours: hall.mealsOnDate(date), currentStatus: hall.currentStatus())
                        } else {
                            Text("Closed")
                                .italic()
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}
