//
//  FitnessSettingsView.swift
//  PennMobile
//
//  Created by Jordan H on 5/13/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

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

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image("pottruck")
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
                            let date = Date()
                            let isOpen = date >= room.open && date <= room.close
                            Text(isOpen ? "Open" : "Closed")
                                .font(.system(size: 14, weight: .light, design: .default))
                                .padding(.vertical, 3)
                                .padding(.horizontal, 6)
                                .foregroundColor(isOpen ? Color.white : Color.labelPrimary)
                                .background(isOpen ? Color.greenLight : Color.redLight)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .frame(height: geo.frame(in: .global).height)
                            Text(formattedHours(open: room.open, close: room.close))
                                .font(.system(size: 14, weight: .light, design: .default))
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
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    // TODO: DELETE THIS REDUNDENCY
    func formattedHours(open: Date, close: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "EST")
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        
        let open = formatter.string(from: open)
        let close = formatter.string(from: close)
        let timesString = "\(open) - \(close)"

        return timesString
    }
}
