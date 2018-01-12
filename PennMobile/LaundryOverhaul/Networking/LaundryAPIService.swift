//
//  LaundryAPIService.swift
//  LaundryTester
//
//  Created by Zhilei Zheng on 2017/10/24.
//  Copyright © 2017年 Zhilei Zheng. All rights reserved.
//
import Foundation
import SwiftyJSON
import PromiseKit

class LaundryAPIService: Requestable {
    
    static let instance = LaundryAPIService()
    
    private let laundryUrl = "https://api.pennlabs.org/laundry/hall"
    private let hallsUrl = "https://api.pennlabs.org/laundry/halls/ids"
    fileprivate let historyUrl = "https://api.pennlabs.org/laundry/usage"
    
    public var idToHalls: [Int: LaundryHall]?
    
    // Prepare the service
    func prepare() {
        if Storage.fileExists(LaundryHall.directory, in: .caches) {
            self.idToHalls = Storage.retrieve(LaundryHall.directory, from: .caches, as: Dictionary<Int, LaundryHall>.self)
        } else {
            loadIds { _ in }
        }
    }
    
    func loadIds(_ callback: @escaping (_ success: Bool) -> ()) {
        fetchIds { (dictionary) in
            self.idToHalls = dictionary
            if let dict = dictionary {
                Storage.store(dict, to: .caches, as: LaundryHall.directory)
            }
            callback(dictionary != nil)
        }
    }
    
    private func fetchIds(callback: @escaping ([Int: LaundryHall]?) -> ()) {
        getRequest(url: hallsUrl) { (dictionary) in
            if let dict = dictionary {
                let json = JSON(dict)
                let hallsDictionary = try? Dictionary<Int, LaundryHall>(json: json)
                callback(hallsDictionary)
            } else {
                callback(nil)
            }
        }
    }
    
    func getUsageData(for id: Int, callback: @escaping ((LaundryUsageData?) -> Void)) {
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
    
    // call passing array of ids to API
    // Returns optional array of halls (nil if network call failed)
    func getHalls(for ids: [Int], callback: @escaping (([LaundryHall]?) -> Void)) {
        for id in ids {
            if LaundryUsageData.dataForRoom[id] == nil {
                getUsageData(for: id, callback: { (usageData) in
                    LaundryUsageData.dataForRoom[id] = usageData
                    if let data = usageData {
                        print(data.id)
                        print(data.name)
                        print(data.numberOfMachines)
                        print(data.usageData)
                    }
                })
            }
        }
        
        if ids.count == 3 {
            getHalls(for: [ids[0]], callback: { (firstHallArray) in
                if firstHallArray == nil {
                    callback(nil)
                    return
                }
                
                var firstCopy = firstHallArray
                self.getHalls(for: [ids[1], ids[2]], callback: { (secondThirdHalls) in
                    if let second = secondThirdHalls {
                        firstCopy?.append(contentsOf: second)
                        callback(firstCopy)
                    } else {
                        callback(nil)
                    }
                })
            })
            return
        }
        
        var url = laundryUrl
        for id in ids {
            url += "/\(id)"
        }
        getRequest(url: url) { (dictionary) in
            if let dict = dictionary {
                let json = JSON(dict)
                if let hallArray = json["halls"].array {
                    var halls = [LaundryHall]()
                    var index = 0
                    for id in ids {
                        halls.append(LaundryHall(json: hallArray[index], id: id))
                        index += 1
                    }
                    callback(halls)
                } else {
                    let laundryHall = LaundryHall(json: json, id: ids[0])
                    callback([laundryHall])
                }
            } else {
                callback(nil)
            }
        }
    }
    
    func getHalls(for halls: [LaundryHall], callback: @escaping (([LaundryHall]?) -> Void)) {
        let ids = halls.map { $0.id }
        getHalls(for: ids, callback: callback)
    }
}

extension LaundryAPIService {
    // Fetch Historical Data for 1 hall
    func getTodaysHistory(for id: Int, callback: @escaping ([Float], [Float]) ->Void){
        let url = historyUrl + "\(id)"
        getRequest(url: url, callback: { (dictionary) in
            if let dict = dictionary {
                let json = JSON(dict)
                var washers = Array<Float>(repeating: 0, count: 26)
                var dryers = Array<Float>(repeating: 0, count: 26)
                if let washerData = json["washer_data"].dictionary, let dryerData = json["dryer_data"].dictionary {
                    for i in 0..<26 {
                        if let currWasher = washerData["\(i)"]?.float {
                            washers[i] = currWasher
                        }
                        if let currDryer = dryerData["\(i)"]?.float {
                            dryers[i] = currDryer
                        }
                    }
                    callback(washers, dryers)
                } else {
                    callback([], [])
                }
            }
            
        })
    }
}

extension Dictionary where Key == Int, Value == LaundryHall {
    init(json: JSON) throws {
        guard let jsonArray = json["halls"].array else {
            throw JSONError.unexpectedRootNode("Result missing halls.")
        }
        self.init()
        for json in jsonArray {
            let id = json["id"].intValue
            let hall = LaundryHall.init(json: json)
            self[id] = hall
        }
    }
}
