//
//  LaundryAPIService.swift
//  LaundryTester
//
//  Created by Josh Doman on 2017/10/24.
//  Copyright © 2017 Penn Labs. All rights reserved.
//
import Foundation
import SwiftyJSON
import PennMobileShared

class OldLaundryAPIService: Requestable {

    static let instance = OldLaundryAPIService()

    fileprivate let laundryUrl = "https://pennmobile.org/api/laundry/rooms"
    fileprivate let idsUrl = "https://pennmobile.org/api/laundry/halls/ids"
    fileprivate let statusURL = "https://pennmobile.org/api/laundry/status"

    public var idToRooms: [Int: OldLaundryRoom]?
    
    private func getCachedLaundryRooms() -> [Int: OldLaundryRoom]? {
        let key = "laundryDataUpgraded"
        if !UserDefaults.standard.bool(forKey: key) {
            Storage.remove(OldLaundryRoom.directory, from: .caches)
            UserDefaults.standard.set(true, forKey: key)
        } else if Storage.fileExists(OldLaundryRoom.directory, in: .caches) {
            return try? Storage.retrieveThrowing(OldLaundryRoom.directory, from: .caches, as: Dictionary<Int, OldLaundryRoom>.self)
        }
        
        return nil
    }

    // Prepare the service
    func prepare(_ completion: @escaping () -> Void) {
        if let cached = getCachedLaundryRooms() {
            self.idToRooms = cached
            completion()
        } else {
            loadIds { (_) in
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }

    func clearDirectory() {
        Storage.remove(OldLaundryRoom.directory, from: .caches)
    }

    func loadIds(_ callback: @escaping (_ success: Bool) -> Void) {
        fetchIds { (dictionary) in
            self.idToRooms = dictionary
            if let dict = dictionary {
                Storage.store(dict, to: .caches, as: OldLaundryRoom.directory)
            }
            callback(dictionary != nil)
        }
    }

    private func fetchIds(callback: @escaping ([Int: OldLaundryRoom]?) -> Void) {
        getRequestData(url: idsUrl) { (data, _, _) in
            if let data = data, let rooms = try? JSONDecoder().decode([OldLaundryRoom].self, from: data) {
                callback(Dictionary(uniqueKeysWithValues: rooms.map { ($0.id, $0) }))
            } else {
                callback(nil)
            }
        }
    }
}

// MARK: - Fetch API
extension OldLaundryAPIService {
    func fetchLaundryData(for ids: [Int], _ callback: @escaping (_ rooms: [OldLaundryRoom]?) -> Void) {
        var rooms = [OldLaundryRoom]()
        var requestsCompleted = 0
        
        for id in ids {
            getRequest(url: "\(laundryUrl)/\(id)") { (dict, _, _) in
                DispatchQueue.main.async {
                    if let dict = dict {
                        let json = JSON(dict)
                        let jsonArray = json["rooms"].arrayValue
                        for json in jsonArray {
                            let room = OldLaundryRoom(json: json)
                            rooms.append(room)
                        }
                    }
                    
                    requestsCompleted += 1
                    if requestsCompleted == ids.count {
                        callback(rooms)
                    }
                }
            }
        }
    }

    func fetchLaundryData(for rooms: [OldLaundryRoom], _ callback: @escaping (_ rooms: [OldLaundryRoom]?) -> Void) {
        let ids: [Int] = rooms.map { $0.id }
        fetchLaundryData(for: ids, callback)
    }
}

// MARK: - Laundry Status API
extension OldLaundryAPIService {
    func checkIfWorking(_ callback: @escaping (_ isWorking: Bool?) -> Void) {
        getRequest(url: statusURL) { (dict, _, _) in
            if let dict = dict {
                let json = JSON(dict)
                let isWorking = json["is_working"].bool
                callback(isWorking)
            } else {
                callback(nil)
            }
        }
    }
}

// MARK: - Room ID Parsing
extension Dictionary where Key == Int, Value == OldLaundryRoom {
    init(json: JSON) throws {
        guard let jsonArray = json["halls"].array else {
            throw NetworkingError.jsonError
        }
        self.init()
        for json in jsonArray {
            let id = json["id"].intValue
            let room = OldLaundryRoom(json: json)
            self[id] = room
        }
    }
}
