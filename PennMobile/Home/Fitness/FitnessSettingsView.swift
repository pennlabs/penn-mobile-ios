//
//  FitnessSettingsView.swift
//  PennMobile
//
//  Created by Jordan H on 5/13/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher
import PennMobileShared

struct FitnessSelectView: View {
    @Binding var showFitnessSettings: Bool
    @ObservedObject var favoritesList: FavoritesList
    var rooms: [FitnessRoom]
    @State var selections: [Int: Bool]

    var body: some View {
        VStack {
            HStack {
                // Button to cancel settings
                Button {
                    showFitnessSettings = false
                } label: {
                    Text("Cancel")
                        .foregroundColor(.blue)
                }
                Spacer()
                Text("Select Favorites")
                Spacer()
                // Button to save settings
                Button {
                    let favorites = selections.keys.filter { selections[$0] == true }
                    FitnessRoom.setPreferences(for: favorites)
                    favoritesList.favorites = favorites
                    showFitnessSettings = false
                } label: {
                    Text("Save")
                        .foregroundColor(.blue)
                }
            }
            .padding([.top, .leading, .trailing])
            List {
                ForEach(rooms) { room in
                    FitnessSelectRowView(room: room, isSelected: selections[room.id]!, action: { selections[room.id] = !selections[room.id]!
                    })
                }
            }
            Spacer()
        }
    }
}

// View for each specific row
struct FitnessSelectRowView: View {
    var room: FitnessRoom
    var isSelected: Bool
    var action: () -> Void
    var hours: (Date, Date) {
        let calendar = Calendar.current
        let currentDate = Date()
        let weekdayIndex = (calendar.component(.weekday, from: currentDate) + 5) % 7
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        
        let openTime = timeFormatter.date(from: room.open[weekdayIndex])!
        let closeTime = timeFormatter.date(from: room.close[weekdayIndex])!

        let openDate = calendar.date(bySettingHour: openTime.hour, minute: openTime.minutes, second: 0, of: currentDate)!
        let closeDate = calendar.date(bySettingHour: closeTime.hour, minute: closeTime.minutes, second: 0, of: currentDate)!
        
        return (openDate, closeDate)
    }
    var isOpen: Bool {
        let date = Date()
        return hours.0 < date && date < hours.1
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                KFImage(room.image_url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 64)
                    .background(Color.grey1)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(room.name)
                        .font(.system(size: 17, weight: .medium))
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                    
                    GeometryReader { geo in
                        HStack(spacing: 6) {
                            Text(isOpen ? "Open" : "Closed")
                                .font(.system(size: 14, weight: .light, design: .default))
                                .padding(.vertical, 3)
                                .padding(.horizontal, 6)
                                .foregroundColor(isOpen ? Color.white : Color.labelPrimary)
                                .background(isOpen ? Color.greenLight : Color.redLight)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .frame(height: geo.frame(in: .global).height)
                            Text(FitnessRoomRow.formattedHours(open: hours.0, close: hours.1, includeEmptyMinutes: false))
                                .font(.system(size: 14, weight: .light, design: .default))
                                .lineLimit(1)
                                .padding(.vertical, 3)
                                .padding(.horizontal, 6)
                                .foregroundColor(Color.labelPrimary)
                                .background(Color.grey5)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .frame(height: geo.frame(in: .global).height)
                        }
                    }
                }
                .frame(height: 64)
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
