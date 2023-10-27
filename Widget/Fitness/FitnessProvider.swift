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

struct FitnessEntry<Configuration>: TimelineEntry {
    let date: Date
    let room: FitnessRoom?
    let configuration: Configuration
}

extension FitnessEntry where Configuration == Void {
    init(date: Date, room: FitnessRoom?) {
        self.init(date: date, room: room, configuration: ())
    }
}

private var cachedRoomData: FitnessRoom?
private var placeHolderRoom: FitnessRoom?

private let cacheAge: TimeInterval = 10 * 60
private var lastFetchDate: Date?
private var refreshTask: Task<Void, Never>?

private func getRoom(roomID: Int) async -> FitnessRoom? {
    let modelRefreshTask : Task<FitnessRoom?, Never> = Task {
        do {
            let fitnessData = await FitnessAPI.instance.fetchFitnessRooms()
            let fitnessRooms = try fitnessData.get()
            let selectedRoom = fitnessRooms.filter {room in
                room.id == roomID
            }
            if(selectedRoom.count > 0) {
                switch await FitnessAPI.instance.fetchFitnessRoomsWithData(rooms: selectedRoom) {
                case .failure:
                    return nil
                case .success(let updatedRooms):
                    return updatedRooms[0]
                }
            } else {
                return nil
            }
        } catch let error {
            print("Couldn't fetch fitness data: \(error)")
            return nil
        }
    }
    let fitnessData : FitnessRoom? = await modelRefreshTask.value
    return fitnessData
}

private func refresh(roomID: Int) async {
    let fitnessData : FitnessRoom? = await getRoom(roomID: roomID)
    cachedRoomData = fitnessData ?? nil
}

private func updatePlaceHolder(roomID: Int) async {
    let fitnessData : FitnessRoom? = await getRoom(roomID: roomID)
    placeHolderRoom = fitnessData ?? nil
}



private func snapshot<ConfigureFitnessWidgetIntent>(configuration: ConfigureFitnessWidgetIntent, roomID: Int) async -> FitnessEntry<ConfigureFitnessWidgetIntent> {
    if refreshTask == nil
        || cachedRoomData == nil
        || (lastFetchDate != nil && Date().timeIntervalSince(lastFetchDate!) > cacheAge)
        || (cachedRoomData!).id != roomID {
        refreshTask = Task {
            lastFetchDate = Date()
            await refresh(roomID: roomID)
        }
    }
    await refreshTask?.value
    return FitnessEntry(date: Date(), room: cachedRoomData, configuration: configuration)
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
        return FitnessEntry(date: Date(), room: placeHolderRoom, configuration: placeholderConfiguration)
    }
}
