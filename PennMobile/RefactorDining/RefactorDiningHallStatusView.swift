//
//  RefactorDiningHallStatusView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/13/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct RefactorDiningHallStatusView: View {
    
    let diningHall: RefactorDiningHall
    init(_ diningHall: RefactorDiningHall) {
        self.diningHall = diningHall
    }
    
    var body: some View {
        HStack(spacing: 8) {
            AsyncImage(url: URL(string: diningHall.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 64)
                    .background(Color.grey1)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            } placeholder: {
                ProgressView()
                    .padding()
                    .frame(width: 100, height: 64)
            }
            .padding(4)
            TimelineView(.everyMinute) { context in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: diningHall.currentStatus().iconString)
                            .font(.system(size: 8))
                        Text(diningHall.statusText())
                            .bold()
                    }
                        .foregroundStyle(diningHall.currentStatus().color)
                        .font(.caption2)
                    Text(diningHall.name)
                        .font(.headline)
                        .bold()
                    RefactorDiningHallHoursStack(hours: diningHall.mealsToday(), currentStatus: diningHall.currentStatus())
                        .frame(maxHeight: 25)
                }
                .animation(.default)
            }
        }
    }
}
