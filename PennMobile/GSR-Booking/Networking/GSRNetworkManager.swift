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
    let reservationURL = "https://api.pennlabs.org/studyspaces/reservations"
    let cancelURL = "https://api.pennlabs.org/studyspaces/cancel"
    let searchUserURL = "https://api.pennlabs.org/studyspaces/user/search?query="
    
    var locations:[Int:String] = [:]
    var bookingRequestOutstanding = false
    
    
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
        var url = "\(availUrl)/\(gsrId)?date=\(dateStr)"
        if let sessionID = GSRUser.getSessionID() {
            url = "\(url)&sessionid=\(sessionID)"
        }
        getRequest(url: url) { (dict, error, statusCode) in
            var rooms: [GSRRoom]!
            if let dict = dict {
                let json = JSON(dict)
                rooms = Array<GSRRoom>(json: json)
            }
            
            if statusCode == 400 && gsrId == 1 {
                // If Session ID invalid, clear it and try again without one
                GSRUser.clearSessionID()
                self.getAvailability(for: gsrId, dateStr: dateStr, callback: callback)
                return
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
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            let url = URL(string: self.bookingUrl)!
            var request = token != nil ? URLRequest(url: url, accessToken: token!) : URLRequest(url: url)
            request.httpMethod = "POST"
            
            let deviceID = getDeviceID()
            request.setValue(deviceID, forHTTPHeaderField: "X-Device-ID")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let start = dateFormatter.string(from: booking.start)
            let end = dateFormatter.string(from: booking.end)
            
            let basicParams = [
                "lid" : String(booking.location.lid),
                "room" : String(booking.roomId),
                "start" : start,
                "end" : end,
            ]
            let extraParams: [String: String]
            if booking.location.service == "wharton" {
                let sessionID: String = booking.sessionId
                extraParams = [
                    "sessionid": sessionID
                ]
            } else {
                let user: GSRUser = booking.user
                extraParams = [
                    "firstname" : user.firstName,
                    "lastname" : user.lastName,
                    "email" : user.email,
                    "phone" : user.phone,
                    "groupname" : booking.groupName,
                    "size" : "2-3"
                ]
            }
            
            let params = basicParams.merging(extraParams, uniquingKeysWith: { (first, _) in first })
            request.httpBody = params.stringFromHttpParameters().data(using: String.Encoding.utf8)
            
            self.bookingRequestOutstanding = true
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                var success = false
                var errorMessage = "Unable to connect to the internet. Please reconnect and try again."
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let data = data, let _ = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                            let json = JSON(data)
                            success = json["results"].boolValue
                            errorMessage = json["error"].stringValue
                        }
                        if errorMessage.contains("\n") {
                            errorMessage = errorMessage.replacingOccurrences(of: "\n", with: " ")
                        }
                    } else {
                        // Session ID is invalid, so clear it
                        GSRUser.clearSessionID()
                    }
                }
                callback(success, errorMessage)
                self.bookingRequestOutstanding = false
            })
            task.resume()
        }
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
        return try parseReservationsFromArray(json: json["reservations"])
    }
    
    func parseReservationsFromArray(json: JSON) throws -> [GSRReservation] {
        guard let jsonArray = json.array else {
            throw NetworkingError.jsonError
        }
        
        var reservations = [GSRReservation]()
        for reservationJSON in jsonArray {
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
        
        if reservation.service == .wharton {
            guard let _ = sessionID else {
                callback(false, "Please log in and try again.")
                return
            }
        }
        deleteReservation(bookingID: reservation.bookingID, sessionID: sessionID, callback: callback)
    }
    
    func deleteReservation(bookingID: String, sessionID: String?, callback: @escaping (_ success: Bool, _ errorMsg: String?) -> Void) {
        let url = URL(string: cancelURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let deviceID = getDeviceID()
        request.setValue(deviceID, forHTTPHeaderField: "X-Device-ID")
        
        var params = ["booking_id": bookingID]
        
        if let sessionID = sessionID {
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
                        } else if let errorMsg = json["error"].string {
                            callback(false, errorMsg)
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

// MARK: - Session ID
extension GSRNetworkManager: PennAuthRequestable {
    
    private var serviceDown: String {
        return "https://servicedown.wharton.upenn.edu/"
    }
    
    private var whartonUrl: String {
        return "https://apps.wharton.upenn.edu/gsr/"
    }
    
    private var shibbolethUrl: String {
        return "https://apps.wharton.upenn.edu/django-shib/Shibboleth.sso/SAML2/POST"
    }

    
    func getSessionID(_ callback: (((_ success: Bool) -> Void))? = nil) {
        self.getSessionIDWithDownFlag { (success, _) in
            callback?(success)
        }
    }
    
    func getSessionIDWithDownFlag(_ callback: @escaping ((_ success: Bool, _ serviceDown: Bool) -> Void)) {
        makeAuthRequest(targetUrl: whartonUrl, shibbolethUrl: shibbolethUrl) { (data, response, error) in
            if let urlStr = response?.url?.absoluteString, urlStr == self.serviceDown {
                callback(false, true)
                return
            }
            
            callback(GSRUser.getSessionID() != nil, false)
        }
    }
}
