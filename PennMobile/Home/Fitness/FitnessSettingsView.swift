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

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                KFImage(room.image_url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 64)
                    .background(Color.grey1)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                Text(room.name)
                    .foregroundColor(.primary)
                    .font(.system(size: 17, weight: .medium))
                    .minimumScaleFactor(0.2)
                    .lineLimit(1)
                    .frame(height: 64)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
