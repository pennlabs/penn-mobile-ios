//
//  LaundryAPIService.swift
//  LaundryTester
//
//  Created by Josh Doman on 2017/10/24.
//  Copyright © 2017 Penn Labs. All rights reserved.
//
import Foundation
import SwiftyJSON

class LaundryAPIService: Requestable {
    
    static let instance = LaundryAPIService()
    
    fileprivate let laundryUrl = "https://api.pennlabs.org/laundry/rooms"
    fileprivate let idsUrl = "https://api.pennlabs.org/laundry/halls/ids"
    
    public var idToRooms: [Int: LaundryRoom]?
    
    // Prepare the service
    func prepare(_ completion: @escaping () -> Void) {
        if Storage.fileExists(LaundryRoom.directory, in: .caches) {
            self.idToRooms = Storage.retrieve(LaundryRoom.directory, from: .caches, as: Dictionary<Int, LaundryRoom>.self)
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
        Storage.remove(LaundryRoom.directory, from: .caches)
    }
    
    func loadIds(_ callback: @escaping (_ success: Bool) -> ()) {
        fetchIds { (dictionary) in
            self.idToRooms = dictionary
            if let dict = dictionary {
                Storage.store(dict, to: .caches, as: LaundryRoom.directory)
            }
            callback(dictionary != nil)
        }
    }
    
    private func fetchIds(callback: @escaping ([Int: LaundryRoom]?) -> ()) {
        getRequest(url: idsUrl) { (dictionary, error, statusCode) in
            if let dict = dictionary {
                let json = JSON(dict)
                let hallsDictionary = try? Dictionary<Int, LaundryRoom>(json: json)
                callback(hallsDictionary)
            } else {
                callback(nil)
            }
        }
    }
}

// MARK: - Fetch API
extension LaundryAPIService {
    func fetchLaundryData(for rooms: [LaundryRoom], _ callback: @escaping (_ rooms: [LaundryRoom]?) -> Void) {
        let ids: String = rooms.map { $0.id }.map { String($0) }.joined(separator: ",")
        let url = "\(laundryUrl)/\(ids)"
        getRequest(url: url) { (dict, error, statusCode) in
            var rooms: [LaundryRoom]?
            if let dict = dict {
                let json = JSON(dict)
                let jsonArray = json["rooms"].arrayValue
                rooms = [LaundryRoom]()
                for json in jsonArray {
                    let room = LaundryRoom(json: json)
                    rooms?.append(room)
                }
            }
            callback(rooms)
        }
    }
}

// MARK: - Room ID Parsing
extension Dictionary where Key == Int, Value == LaundryRoom {
    init(json: JSON) throws {
        guard let jsonArray = json["halls"].array else {
            throw NetworkingError.jsonError
        }
        self.init()
        for json in jsonArray {
            let id = json["id"].intValue
            let room = LaundryRoom(json: json)
            self[id] = room
        }
    }
}
