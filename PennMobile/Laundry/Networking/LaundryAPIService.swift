//
//  LaundryAPIService.swift
//  LaundryTester
//
//  Created by Josh Doman on 2017/10/24.
//  Copyright © 2017 Penn Labs. All rights reserved.
//
import Foundation
import SwiftyJSON
import PromiseKit

class LaundryAPIService: Requestable {
    
    static let instance = LaundryAPIService()
    
    fileprivate let laundryUrl = "https://api.pennlabs.org/laundry/hall"
    fileprivate let hallsUrl = "https://api.pennlabs.org/laundry/halls/ids"
    fileprivate let historyUrl = "https://api.pennlabs.org/laundry/usage"
    
    public var idToRooms: [Int: LaundryRoom]?
    
    // Prepare the service
    func prepare() {
        if Storage.fileExists(LaundryRoom.directory, in: .caches) {
            self.idToRooms = Storage.retrieve(LaundryRoom.directory, from: .caches, as: Dictionary<Int, LaundryRoom>.self)
        } else {
            loadIds { _ in }
        }
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
        getRequest(url: hallsUrl) { (dictionary) in
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
    func fetchLaundryData(for rooms: [LaundryRoom], withUsageData: Bool, _ callback: @escaping (_ success: Bool) -> Void) {
        let ids = rooms.map { $0.id }
        fetchMachineData(for: ids) { (machineDataArray) in
            if machineDataArray == nil {
                callback(false)
                return
            }
            
            if !withUsageData {
                for machineData in machineDataArray! {
                    LaundryMachineData.set(laundryMachineData: machineData)
                }
                callback(true)
                return
            }
            
            self.fetchUsageData(for: ids, callback: { (usageDataArray) in
                if usageDataArray == nil {
                    callback(false)
                    return
                }
                
                for machineData in machineDataArray! {
                    LaundryMachineData.set(laundryMachineData: machineData)
                }
                
                for usageData in usageDataArray! {
                    LaundryUsageData.set(usageData: usageData, for: usageData.id)
                }
                
                callback(true)
            })
        }
    }
}

// MARK: - MachineData API
extension LaundryAPIService {
    fileprivate func fetchMachineData(for ids: [Int], _ callback: @escaping ([LaundryMachineData]?) -> Void) {
        if ids.count == 3 {
            fetchMachineData(for: [ids[0]]) { (firstMachineDataArray) in
                if firstMachineDataArray == nil {
                    callback(nil)
                    return
                }
                
                var finalArray = firstMachineDataArray
                self.fetchMachineData(for: [ids[1], ids[2]]) { (secondMachineDataArray) in
                    if let secondArray = secondMachineDataArray {
                        finalArray?.append(contentsOf: secondArray)
                        callback(finalArray)
                    } else {
                        callback(nil)
                    }
                }
            }
            return
        }
        
        var url = laundryUrl
        for id in ids {
            url += "/\(id)"
        }
        
        getRequest(url: url) { (dictionary) in
            if let dict = dictionary {
                let json = JSON(dict)
                if let machineDataArray = LaundryMachineData.getMachineDataArray(json: json, ids: ids) {
                    callback(machineDataArray)
                } else {
                    let machineData = LaundryMachineData(json: json, id: ids[0])
                    callback([machineData])
                }
            } else {
                callback(nil)
            }
        }
    }
}

// MARK: - UsageData API
extension LaundryAPIService {
    // Callback is passed a boolean representing a success or failure of network call
    fileprivate func fetchUsageData(for ids: [Int], callback: @escaping ([LaundryUsageData]?) -> Void) {
        LaundryUsageData.clearIfNewDay()
        let newIds = ids.filter { !LaundryUsageData.containsUsageData(for: $0) }
        
        getUsageData(for: newIds) { (newUsageDataArray) in
            callback(newUsageDataArray)
        }
    }
    
    private func getUsageData(for id: Int, callback: @escaping ((LaundryUsageData?) -> Void)) {
        let url = "\(historyUrl)/\(id)"
        getRequest(url: url) { (dict) in
            if let dict = dict {
                let json = JSON(dict)
                let usageData = try? LaundryUsageData(id: id, json: json)
                callback(usageData)
            } else {
                callback(nil)
            }
        }
    }
    
    private func getUsageData(for ids: [Int], callback: @escaping (([LaundryUsageData]?) -> Void)) {
        if ids.isEmpty {
            callback([])
            return
        }
        
        let firstId = ids[0]
        var remainingIds = ids
        remainingIds.remove(at: 0)
        getUsageData(for: firstId) { (usageData) in
            guard let usageData = usageData else {
                callback(nil)
                return
            }
            
            self.getUsageData(for: remainingIds, callback: { (usageDataArray) in
                if usageDataArray == nil {
                    callback(nil)
                    return
                }
                
                var newUsageDataArray = usageDataArray!
                newUsageDataArray.append(usageData)
                callback(newUsageDataArray)
            })
        }
    }
}

// MARK: - MultiRoom Parsing
extension LaundryMachineData {
    fileprivate static func getMachineDataArray(json: JSON, ids: [Int]) -> [LaundryMachineData]? {
        guard let jsonArray = json["halls"].array else {
            return nil
        }
        
        var dataArray = [LaundryMachineData]()
        var i = 0
        for json in jsonArray {
            dataArray.append(LaundryMachineData(json: json, id: ids[i]))
            i += 1
        }
        return dataArray
    }
}

// MARK: - Room ID Parsing
extension Dictionary where Key == Int, Value == LaundryRoom {
    init(json: JSON) throws {
        guard let jsonArray = json["halls"].array else {
            throw JSONError.unexpectedRootNode("Result missing halls.")
        }
        self.init()
        for json in jsonArray {
            let id = json["id"].intValue
            let room = LaundryRoom(json: json)
            self[id] = room
        }
    }
}
