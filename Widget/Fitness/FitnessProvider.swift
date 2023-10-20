//
//  FitnessProvider.swift
//  PennMobile
//
//  Created by Pulkith Paruchuri on 10/8/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import Foundation
import WidgetKit
import Intents
import PennMobileShared

let intentIDToRoomID = [0:0,1:7,2:3,3:2,4:1,5:4,6:6,7:5,8:9,9:8]

struct FitnessEntry<Configuration>: TimelineEntry {
    let date: Date
    let rooms: [FitnessRoom]?
    let configuration: Configuration
}

extension FitnessEntry where Configuration == Void {
    init(date: Date, rooms: [FitnessRoom]?) {
        self.init(date: date, rooms: rooms, configuration: ())
    }
}

private var cachedRoomData: [FitnessRoom]?
private let cacheAge: TimeInterval = 10 * 60
private var lastFetchDate: Date?
private var refreshTask: Task<Void, Never>?

private func refresh(roomID: Int) async {
    let modelRefreshTask = Task {
        do {
            let fitnessData = await FitnessAPI.instance.fetchFitnessRooms()
            let fitnessRooms = try fitnessData.get()
            let selectedRoom = fitnessRooms.filter {room in
                room.id == roomID
            }
            if(selectedRoom.count > 0) {
                switch await FitnessAPI.instance.fetchFitnessRoomsWithData(rooms: selectedRoom) {
                case .failure:
                    return selectedRoom
                case .success(let updatedRooms):
                    cachedRoomData = updatedRooms
                    return updatedRooms
                }
            } else {
                return cachedRoomData ?? []
            }
        } catch let error {
            print("Couldn't fetch fitness data: \(error)")
            return cachedRoomData ?? []
        }
    }
    let fitnessData : [FitnessRoom] = await modelRefreshTask.value
    cachedRoomData = fitnessData
}

private func snapshot<ConfigureFitnessWidgetIntent>(configuration: ConfigureFitnessWidgetIntent, roomID: Int) async -> FitnessEntry<ConfigureFitnessWidgetIntent> {
    if refreshTask == nil
        || cachedRoomData == nil || (cachedRoomData!).count == 0
        || (lastFetchDate != nil && Date().timeIntervalSince(lastFetchDate!) > cacheAge)
        || (cachedRoomData!)[0].id != roomID {
        refreshTask = Task {
            lastFetchDate = Date()
            await refresh(roomID: roomID)
        }
    }
    await refreshTask?.value
    
    return FitnessEntry(date: Date(), rooms: cachedRoomData, configuration: configuration)
}

private func timeline<Configuration>(configuration: Configuration, roomID: Int) async -> Timeline<FitnessEntry<Configuration>> {
    await Timeline(entries: [snapshot(configuration: configuration, roomID: roomID)], policy: .after(Calendar.current.date(byAdding: .minute, value: 10, to: Date())!))
}

struct IntentFitnessProvider<Intent: ConfigureFitnessWidgetIntent>: IntentTimelineProvider {
    let placeholderConfiguration: Intent.Configuration
    
    func getSnapshot(for intent: Intent, in context: Context, completion: @escaping (FitnessEntry<Intent.Configuration>) -> Void) {
        Task {
            let roomID = intent.configuration.complex.rawValue //ID of Fitness Complex in backend should match "Index" field of Fitness Complex in Intents Enum
            completion(await snapshot(configuration: intent.configuration, roomID: roomID))
        }
    }
    
    func getTimeline(for intent: Intent, in context: Context, completion: @escaping (Timeline<FitnessEntry<Intent.Configuration>>) -> Void) {
        Task {
            let roomID = intent.configuration.complex.rawValue
            completion(await timeline(configuration: intent.configuration, roomID: roomID))
        }
    }
    
    func placeholder(in context: Context) -> FitnessEntry<Intent.Configuration> {
        FitnessEntry(date: Date(), rooms: nil, configuration: placeholderConfiguration)
    }
}
