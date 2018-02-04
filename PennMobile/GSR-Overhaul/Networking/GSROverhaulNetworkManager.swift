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
    
    let availUrl = "http://api.pennlabs.org/studyspaces/availability"
    let locationsUrl = "http://api.pennlabs.org/studyspaces/locations"
    let bookingUrl = "http://api.pennlabs.org/studyspaces/book"
    
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
    
    func getAvailability(for gsrId: Int, date: GSROverhaulDate, callback: @escaping ((_ rooms: [GSRRoom]?) -> Void)) {
        let dateStr = date.string
        let url = "\(availUrl)/\(gsrId)?date=\(dateStr)&available=true"
        getRequest(url: url) { (dict) in
            var rooms: [GSRRoom]!
            if let dict = dict {
                let json = JSON(dict)
                rooms = Array<GSRRoom>(json: json)
            }
            callback(rooms)
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
    
    func makeBooking(for booking: GSRBooking, _ callback: @escaping (_ success: Bool) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let start = dateFormatter.string(from: booking.start)
        let end = dateFormatter.string(from: booking.end)
        let user: GSRUser = booking.user
        let params: [String: String] = [
            "building" : String(booking.locationId),
            "room" : String(booking.roomId),
            "start" : start,
            "end" : end,
            "firstname" : user.firstName,
            "lastname" : user.lastName,
            "email" : user.email,
            "phone" : user.phone,
            "groupname" : booking.groupName,
            "size" : "2-3"
        ]
        
        guard let url = URL(string: bookingUrl) else { return }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = params.stringFromHttpParameters().data(using: String.Encoding.utf8);
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            if let data = data {
                let json = JSON(data)
                callback(json["results"].boolValue)
            } else {
                callback(false)
            }
        })
        task.resume()
    }
}

extension Array where Element == GSRRoom {
    init(json: JSON) {
        self.init()
        let roomArray = json["rooms"].arrayValue
        for roomJSON in roomArray {
            if let room = try? GSRRoom(json: roomJSON) {
                self.append(room)
            }
        }
    }
}

extension GSRRoom {
    convenience init(json: JSON) throws {
        guard let name = json["name"].string, let id = json["room_id"].int else {
            throw NetworkingError.jsonError
        }
        
        let capacity = json["capacity"].intValue
        let imageUrl = json["thumbnail"].string
        
        var times = [GSRTimeSlot]()
        let jsonTimeArray = json["times"].arrayValue
        for timeJSON in jsonTimeArray {
            if let time = try? GSRTimeSlot(roomId: id, json: timeJSON), time.isAvailable {
                if let prevTime = times.last, prevTime.endTime == time.startTime {
                    times.last?.next = time
                    time.prev = times.last
                }
                times.append(time)
            }
        }
        self.init(name: name, id: id, imageUrl: imageUrl, capacity: capacity, timeSlots: times)
    }
}

extension GSRTimeSlot {
    convenience init(roomId: Int, json: JSON) throws {
        guard let isAvailable = json["available"].bool,
            let startStr = json["start"].string,
            let endStr = json["end"].string else {
                throw NetworkingError.jsonError
        }
        
        let startDate = try GSRTimeSlot.extractDate(from: startStr)
        let endDate = try GSRTimeSlot.extractDate(from: endStr)
        self.init(roomId: roomId, isAvailable: isAvailable, startTime: startDate, endTime: endDate)
    }
    
    private static func extractDate(from dateString: String) throws -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: dateString) else {
            throw NetworkingError.jsonError
        }
        return date
    }
}
