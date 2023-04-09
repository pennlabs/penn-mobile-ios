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

    var body: some View {
        return List {
            Text("Fitness")
                .font(.system(size: 21, weight: .semibold))
                .foregroundColor(.primary)

            ForEach(rooms) { room in
                FitnessRoomRow(for: room)
                    .padding(.vertical, 4)
            }
        }
        .task {
            await triggerRefresh()
        }
        .navigationBarHidden(false)
        .listStyle(.plain)
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
}

struct FitnessView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessView()
    }
}
