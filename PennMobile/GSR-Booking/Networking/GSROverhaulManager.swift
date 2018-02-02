//
//  NetworkManager.swift
//  GSR
//
//  Created by Zhilei Zheng on 01/02/2018.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import Foundation
import SwiftyJSON


class GSROverhaulManager: NSObject, Requestable {
    
    static let instance = GSROverhaulManager()
    
    let availUrl = "http://api.pennlabs.org/studyspaces/availability/"
    let locationsUrl = "http://api.pennlabs.org/studyspaces/locations"
    
    var locations:[Int:String] = [:]
    
    
    func getLocations (callback: @escaping (([Int:String]?) -> Void)) {
        let url = locationsUrl
        getRequest(url: url) { (dict) in
            if let dict = dict {
                let json = JSON(dict)
                self.locations = self.parseLocations(json: json)
                callback(self.locations)
            } else {
                callback(nil)
            }
        }
    }
    
    func getAvailability (for gsrId: Int, callback: @escaping (([GSRRoom]?) -> Void)) {
        let url = "\(availUrl)\(gsrId)"
        getRequest(url: url) { (dict) in
            if let dict = dict {
                let json = JSON(dict)
                let rooms = self.parseRooms(json: json)
            } else {
                callback(nil)
            }
        }
    }
    
    private func parseLocations(json:JSON) -> [Int:String] {
        var locations:[Int:String] = [:]
        if let jsonArray = json["locations"].array {
            for json in jsonArray {
                let id = json["id"].intValue
                let name = json["name"].stringValue
                locations[id] = name
            }
        }
        return locations
    }
    
    private func parseRooms(json:JSON) -> [GSRRoom] {
        var rooms = [GSRRoom]()
        let roomArray = json["rooms"].arrayValue
        for roomJSON in roomArray {
            let room = GSRRoom(json: roomJSON)
            rooms.append(room)
            return rooms
        }
        return rooms
    }
}

extension GSRRoom {
    init(json: JSON) {
        let capacity = json["capacity"].intValue
        let name = json["name"].stringValue
        let id = json["room_id"].intValue
        let imageUrl = json["thumbnail"].stringValue
        self.init(name: name, id: id, imgUrl: imageUrl, capacity: capacity)
        let jsonTimeArray = json["times"].arrayValue
        for timeJSON in jsonTimeArray {
            let time = GSRTimeSlot(json: timeJSON)
            self.addTimeSlot(time: time)
        }
    }
}

extension GSRTimeSlot {
    init(json: JSON) {
        let isAvailable = json["available"].boolValue
        let startDate = Date().extractDate(from: json["start"].stringValue)
        let endDate = Date().extractDate(from: json["end"].stringValue)
        self.init(isAvailable: isAvailable, startTime: startDate, endTime: endDate)
    }

}

extension Date {
    func extractDate(from dateString: String) -> Date {
        let shortenDateString = dateString.substring(to: dateString.index(dateString.endIndex, offsetBy: -6))
        print(shortenDateString) // test print
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: shortenDateString)
        print(date) // test print
        return date!
    }
}

