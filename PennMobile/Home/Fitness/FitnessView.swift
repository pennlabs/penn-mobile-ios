//
//  FitnessView.swift
//  PennMobile
//
//  Created by Jordan H on 4/7/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct FitnessView: View {
    @State var rooms: [FitnessRoom] = []
    @State var showFitnessSettings = false
    @StateObject var favoritesList = FavoritesList()

    var body: some View {
        ScrollView {
            HStack {
                Text("Favorites")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Button {
                    showFitnessSettings.toggle()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(Color.grey1)
                }
            }
            .modifier(ListRowModifier())
            ForEach(rooms) { room in
                if favoritesList.favorites.contains(room.id) {
                    FitnessRoomRow(room: room)
                        .modifier(ListRowModifier())
                        .padding(.vertical, 4)
                }
            }
            HStack {
                Text("Others")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .modifier(ListRowModifier())
            ForEach(rooms) { room in
                if !favoritesList.favorites.contains(room.id) {
                    FitnessRoomRow(room: room)
                        .modifier(ListRowModifier())
                        .padding(.vertical, 4)
                }
            }
        }
        .task {
            await triggerRefresh()
        }
        .navigationBarHidden(false)
        .listStyle(.plain)
        .sheet(isPresented: $showFitnessSettings) {
            FitnessSelectView(showFitnessSettings: $showFitnessSettings, favoritesList: favoritesList, rooms: rooms, selections: getSelections())
        }
    }
    
    func triggerRefresh() async {
        switch await FitnessAPI.instance.fetchFitnessRooms() {
        case .failure:
            rooms = []
        case .success(let roomsResult):
            rooms = roomsResult
            switch await FitnessAPI.instance.fetchFitnessRoomsWithData(rooms: roomsResult) {
            case .failure:
                return
            case .success(let updatedRooms):
                rooms = updatedRooms
            }
        }
    }
    
    func getSelections() -> [Int: Bool] {
        var selections = [Int: Bool]()
        for room in rooms {
            selections[room.id] = favoritesList.favorites.contains(room.id)
        }
        return selections
    }
}

struct FitnessView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessView()
    }
}

extension FitnessRoom {
    static func setPreferences(for ids: [Int]) {
        UserDefaults.standard.setFitnessPreferences(to: ids)
        UserDBManager.shared.saveFitnessPreferences(for: ids)
    }

    static func setPreferences(for rooms: [FitnessRoom]) {
        let ids = rooms.map { $0.id }
        FitnessRoom.setPreferences(for: ids)
    }

    static func getPreferences() -> [Int] {
        if let ids = UserDefaults.standard.getFitnessPreferences() {
            return ids
        }
        return []
    }
}

class FavoritesList: ObservableObject {
    @Published var favorites: [Int] = []
    
    init() {
        self.favorites = FitnessRoom.getPreferences()
    }
}

struct ListRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        Group {
            content
                .padding([.leading, .trailing])
            Divider()
        }
    }
}
