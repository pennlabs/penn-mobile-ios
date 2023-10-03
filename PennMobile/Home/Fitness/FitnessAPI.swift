//
//  FitnessAPI.swift
//  PennMobile
//
//  Created by Jordan H on 4/7/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON
import PennMobileShared

class FitnessAPI: Requestable {

    static let instance = FitnessAPI()

    let fitnessRoomsUrl = "https://pennmobile.org/api/penndata/fitness/rooms/"
    let fitnessDetailUrl = "https://pennmobile.org/api/penndata/fitness/usage/" // + room ID
    
    func fetchFitnessRooms() async -> Result<[FitnessRoom], NetworkingError> {
        guard let (data, _) = try? await URLSession.shared.data(from: URL(string: fitnessRoomsUrl)!) else {
            return .failure(.serverError)
        }
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        do {
            let rooms = try decoder.decode([FitnessRoom].self, from: data)
            return .success(rooms.sorted(by: { $0.name < $1.name }))
        } catch {
            return .failure(.parsingError)
        }
    }
    
    func fetchFitnessPastData(roomID: Int, date: Date = Date(), num_samples: Int = 3, group_by: String = "week", field: String = "count") async -> Result<FitnessRoomData, NetworkingError> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let urlString = fitnessDetailUrl + "\(roomID)/?date=\(dateString)&num_samples=\(num_samples)&group_by=\(group_by)&field=\(field)"
        guard let (data, _) = try? await URLSession.shared.data(from: URL(string: urlString)!) else {
            return .failure(.serverError)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        do {
            let data = try decoder.decode(FitnessRoomData.self, from: data)
            return .success(data)
        } catch {
            return .failure(.parsingError)
        }
    }

    func fetchFitnessRoomsWithData(rooms: [FitnessRoom]) async -> Result<[FitnessRoom], NetworkingError> {
        return await withTaskGroup(of: FitnessRoom.self) { group in
            var updatedRooms = [FitnessRoom]()
            updatedRooms.reserveCapacity(rooms.count)
            for room in rooms {
                group.addTask {
                    switch await self.fetchFitnessPastData(roomID: room.id) {
                    case .success(let data):
                        var updatedRoom = room
                        updatedRoom.data = data
                        return updatedRoom
                    case .failure:
                        return room
                    }
                }
            }
            for await updatedRoom in group {
                updatedRooms.append(updatedRoom)
            }
            return .success(updatedRooms.sorted(by: { $0.name < $1.name }))
        }
    }
    
    // Other facilities for future reference
    // sheerr     =  "Sheerr Pool"
    // ringe      =  "Penn Squash Center", "Ringe"
    // climbing   =  "Climbing Wall"
    // membership =  "Membership"
    // fox        =  "Fox Fitness"
    // pottruck   =  "Pottruck", "Pottruck Fitness"
    // rockwell   =  "Pottruck Court", "Rockwell"
}
