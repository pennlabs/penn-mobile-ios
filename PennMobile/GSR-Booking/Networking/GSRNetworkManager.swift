//
//  NetworkManager.swift
//  GSR
//
//  Created by Zhilei Zheng on 01/02/2018.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import Foundation
import SwiftyJSON


class GSRNetworkManager: NSObject, Requestable {
    
    static let instance = GSRNetworkManager()
    
    let availUrl = "https://api.pennlabs.org/studyspaces/availability"
    let locationsUrl = "https://api.pennlabs.org/studyspaces/locations"
    let bookingUrl = "https://api.pennlabs.org/studyspaces/book"
    let reservationURL = "http://api-dev.pennlabs.org/studyspaces/reservations"
    let cancelURL = "http://api-dev.pennlabs.org/studyspaces/cancel"
    
    var locations:[Int:String] = [:]
    
    
    func getLocations (callback: @escaping (([Int:String]?) -> Void)) {
        let url = locationsUrl
        getRequest(url: url) { (dict, error, statusCode) in
            if let dict = dict {
                let json = JSON(dict)
                self.locations = self.parseLocations(json: json)
                callback(self.locations)
            } else {
                callback(nil)
            }
        }
    }
    
    func getAvailability(for gsrId: Int, date: GSRDate, callback: @escaping ((_ rooms: [GSRRoom]?) -> Void)) {
        self.getAvailability(for: gsrId, dateStr: date.string) { (rooms) in
            callback(rooms)
        }
    }

    func getAvailability(for gsrId: Int, dateStr: String, callback: @escaping ((_ rooms: [GSRRoom]?) -> Void)) {
        let url = "\(availUrl)/\(gsrId)?date=\(dateStr)"
        getRequest(url: url) { (dict, error, statusCode) in
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
    
    func makeBooking(for booking: GSRBooking, _ callback: @escaping (_ success: Bool, _ failureMessage: String?) -> Void) {
        if booking.location.service == "wharton" {
            WhartonGSRNetworkManager.instance.bookRoom(booking: booking) { (success, errorMsg) in
                callback(success, errorMsg)
            }
        } else {
            makeLibcalBooking(for: booking, callback)
        }
    }
    
    func makeLibcalBooking(for booking: GSRBooking, _ callback: @escaping (_ success: Bool, _ failureMessage: String?) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let start = dateFormatter.string(from: booking.start)
        let end = dateFormatter.string(from: booking.end)
        let user: GSRUser = booking.user
        let params: [String: String] = [
            "building" : String(booking.location.lid),
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
            var success = false
            var errorMessage = "Unable to connect to the internet. Please reconnect and try again."
            if let data = data, let _ = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                let json = JSON(data)
                success = json["results"].boolValue
                errorMessage = json["error"].stringValue
            }
            if errorMessage.contains("\n") {
                errorMessage = errorMessage.replacingOccurrences(of: "\n", with: " ")
            }
            callback(success, errorMessage)
        })
        task.resume()
    }
}

// MARK: - Get Reservatoins
extension GSRNetworkManager {
    func getReservations(sessionID: String?, email: String?, _ callback: @escaping (_ reservations: [GSRReservation]?) -> Void) {
        let url: String
        if let sessionID = sessionID, let email = email {
            url = "\(reservationURL)?sessionid=\(sessionID)&email=\(email)"
        } else if let sessionID = sessionID {
            url = "\(reservationURL)?sessionid=\(sessionID)"
        } else if let email = email {
            url = "\(reservationURL)?email=\(email)"
        } else {
            url = reservationURL
        }
        getRequest(url: url) { (dict, error, status) in
            var reservations: [GSRReservation]? = nil
            if let dict = dict {
                let json = JSON(dict)
                reservations = try? self.parseReservation(json: json)
            }
            callback(reservations)
        }
    }
    
    func parseReservation(json: JSON) throws -> [GSRReservation] {
        guard json["error"].string == nil else {
            throw NetworkingError.authenticationError
        }
        guard let reservationJSONArray = json["reservations"].array else {
            throw NetworkingError.jsonError
        }
        
        var reservations = [GSRReservation]()
        for reservationJSON in reservationJSONArray {
            guard let roomName = reservationJSON["name"].string,
                let gid = reservationJSON["gid"].int,
                let lid = reservationJSON["lid"].int,
                let bookingID = reservationJSON["booking_id"].string,
                let startDateStr = reservationJSON["fromDate"].string,
                let endDateStr = reservationJSON["toDate"].string,
                let serviceStr = reservationJSON["service"].string,
                let service = GSRService(rawValue: serviceStr) else {
                    throw NetworkingError.jsonError
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            guard let startDate = formatter.date(from: startDateStr),
                let endDate = formatter.date(from: endDateStr) else {
                    throw NetworkingError.jsonError
            }
            
            let reservation = GSRReservation(roomName: roomName, gid: gid, lid: lid, bookingID: bookingID, startDate: startDate, endDate: endDate, service: service)
            reservations.append(reservation)
        }
        return reservations
    }
}

// MARK: - Delete Reservation
extension GSRNetworkManager {
    func deleteReservation(reservation: GSRReservation, sessionID: String?, callback: @escaping (_ success: Bool, _ errorMsg: String?) -> Void) {
        let url = URL(string: cancelURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var params = ["booking_id": reservation.bookingID]
        
        if reservation.service == .wharton {
            guard let sessionID = sessionID else {
                callback(false, "Please log in and try again.")
                return
            }
            params["sessionid"] = sessionID
        }
        request.httpBody = params.stringFromHttpParameters().data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if error != nil {
                callback(false, "Unable to connect to the Internet.")
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data, let _ = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        let json = JSON(data)
                        if let result = json["result"].array?.first {
                            let success = result["cancelled"].boolValue
                            let errorMsg = result["error"].string
                            callback(success, errorMsg)
                            return
                        }
                    }
                }
                callback(false, "Something went wrong. Please try again.")
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
        guard let name = json["name"].string, let roomId = json["room_id"].int, let gid = json["gid"].int else {
            throw NetworkingError.jsonError
        }
        
        let capacity = json["capacity"].intValue
        let imageUrl = json["thumbnail"].string
        
        var times = [GSRTimeSlot]()
        let jsonTimeArray = json["times"].arrayValue
        for timeJSON in jsonTimeArray {
            if let time = try? GSRTimeSlot(roomId: roomId, json: timeJSON) {
                if let prevTime = times.last, prevTime.endTime == time.startTime {
                    times.last?.next = time
                    time.prev = times.last
                }
                times.append(time)
            }
        }
        self.init(name: name, roomId: roomId, gid: gid, imageUrl: imageUrl, capacity: capacity, timeSlots: times)
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
