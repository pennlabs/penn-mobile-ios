//
//  WhartonGSRNetworkManager.swift
//  PennMobile
//
//  Created by Josh Doman on 1/20/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

class WhartonGSRNetworkManager: NSObject, Requestable {
    
    static let instance = WhartonGSRNetworkManager()
    
    let availUrl = "https://apps.wharton.upenn.edu/gsr/api/app/grid_view"
    let availUrlNoSessionID = "https://api.pennlabs.org/studyspaces/gsr"
    let bookURL = "https://apps.wharton.upenn.edu/gsr/reserve"
    
    func getAvailability(sessionID: String?, date: GSRDate, callback: @escaping ((_ rooms: [GSRRoom]?) -> Void)) {
        if sessionID == nil {
            getAvailabilityWithoutSessionID(date: date, callback: callback)
            return
        }
        
        let urlStr = "\(availUrl)/?search_time=\(date.string)%2005:00&building_code=1"
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        let sessionCookie = "sessionid=\(sessionID!)"
        request.addValue(sessionCookie, forHTTPHeaderField: "Cookie")
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            if error != nil {
                // indicates that user is unable to connect to internet
                callback(nil)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data, let _ = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                            //data recieved and parsed successfully
                            if let dict = json {
                                let json = JSON(dict)
                                do {
                                    let rooms = try self.parseAvailabilityJSON(json)
                                    if !rooms.isEmpty {
                                        callback(rooms)
                                        return
                                    }
                                } catch NetworkingError.authenticationError {
                                    // Clear session ID if no longer valid
                                    UserDefaults.standard.clearSessionID()
                                } catch {
                                }
                            }
                        }
                    }
                }
                // Unless a valid set of rooms is returns, ping the server
                self.getAvailabilityWithoutSessionID(date: date, callback: callback)
            }
            
        })
        task.resume()
    }
    
    func getAvailabilityWithoutSessionID(date: GSRDate, callback: @escaping ((_ rooms: [GSRRoom]?) -> Void)) {
        let url = "\(availUrlNoSessionID)?date=\(date.string)"
        getRequest(url: url) { (dict, _, _) in
            var rooms: [GSRRoom]? = nil
            if let dict = dict {
                let json = JSON(dict)
                rooms = try? self.parseAvailabilityJSON(json)
            }
            callback(rooms)
        }
    }
    
    func bookRoom(booking: GSRBooking, callback: @escaping ((_ success: Bool, _ errorMsg: String?) -> Void)) {
        let sessionID: String = booking.sessionId
        let urlStr = getBookingUrl(for: booking)
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        let sessionCookie = "sessionid=\(sessionID)"
        request.addValue(sessionCookie, forHTTPHeaderField: "Cookie")
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if error != nil {
                // indicates that user is unable to connect to internet
                callback(false, "Unable to connect to Internet.")
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data, let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue), let csrfHeaderStr = httpResponse.allHeaderFields["Set-Cookie"] as? String {
                        let csrfHeader = self.getMatch(for: "csrftoken=(.*?);", in: csrfHeaderStr)
                        let str = dataString as String
                        let csrfToken = self.getMatch(for: "<input name=\"csrfmiddlewaretoken\" type=\"hidden\" value=\"(.*?)\"/>", in: str)
                        
                        self.reserveRoom(booking: booking, csrfHeader: csrfHeader, csrfToken: csrfToken, callback: { (success, errorMsg)  in
                            callback(success, errorMsg)
                        })
                        return
                    }
                }
                UserDefaults.standard.clearSessionID()
                callback(false, "Login invalid. Please resubmit and try again.")
            }
            
        })
        task.resume()
    }
    
    func reserveRoom(booking: GSRBooking, csrfHeader: String, csrfToken: String, callback: @escaping ((_ success: Bool, _ errorMsg: String?) -> Void)) {
        let sessionID: String = booking.sessionId
        let urlStr = getBookingUrl(for: booking)
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        let sessionCookie = "sessionid=\(sessionID); csrftoken=\(csrfHeader)"
        request.addValue(sessionCookie, forHTTPHeaderField: "Cookie")
        request.addValue(bookURL, forHTTPHeaderField: "Referer")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let startStr = dateFormatter.string(from: booking.start)
        
        dateFormatter.dateFormat = "EEE MMM d H:mm:ss yyyy"
        let endStr = dateFormatter.string(from: booking.end)
        
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let dateStr = dateFormatter.string(from: booking.start)
        
        let params = ["csrfmiddlewaretoken": csrfToken, "room": String(booking.roomId), "start_time": startStr, "end_time": endStr, "date": dateStr]
        request.httpBody = params.stringFromHttpParameters().data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if error != nil {
                // indicates that user is unable to connect to internet
                callback(false, nil)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data, let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        let str = dataString as String
                        if str.contains("errorlist") {
                            let errorMsg = self.getMatch(for: "class=\"errorlist\"><li>(.*?)</li>", in: str)
                            callback(false, errorMsg)
                            return
                        } else {
                            callback(true, nil)
                            return
                        }
                    }
                }
                callback(false, nil)
            }
            
        })
        task.resume()
    }
    
    func getMatch(for pattern: String, in text: String) -> String {
        let regex = try! NSRegularExpression(pattern: pattern)
        let result = regex.matches(in: text as String, range:NSMakeRange(0, text.utf16.count))
        let r = result[0].rangeAt(1)
        let start = text.index(text.startIndex, offsetBy: r.location)
        let end = text.index(text.startIndex, offsetBy: r.location + r.length)
        return text[start..<end]
    }
    
    func getBookingUrl(for booking: GSRBooking) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let startStr = dateFormatter.string(from: booking.start)
        let duration = booking.start.minutesFrom(date: booking.end)
        
        return "\(bookURL)/\(booking.roomId)/\(startStr)/?d=\(duration)"
    }
}

extension WhartonGSRNetworkManager {
    func parseAvailabilityJSON(_ json: JSON) throws -> [GSRRoom] {
        guard json["error"].string == nil else {
            throw NetworkingError.authenticationError
        }
        let timesJSONArray = json["times"].arrayValue.flatMap { $0.arrayValue }
        let timesArray = try timesJSONArray.map { (json) -> GSRTimeSlot in
            return try GSRTimeSlot(json: json)
            }
        
        var rooms = [GSRRoom]()
        
        let roomJSONArray = json["rooms"].arrayValue
        let now = Date()
        for jsonStr in roomJSONArray {
            let str = jsonStr.stringValue
            let strArr = str.split(separator: " ")
            let name = String(strArr[1])
            guard let id = Int(strArr[2]) else { break }
            
            var times = [GSRTimeSlot]()
            for time in timesArray.filter({ $0.roomId == id }) {
                if time.endTime <= now { continue }
                if let prevTime = times.last, prevTime.endTime == time.startTime {
                    times.last?.next = time
                    time.prev = times.last
                }
                times.append(time)
            }
            
            let room = GSRRoom(name: name, roomId: id, gid: 9999, imageUrl: nil, capacity: 5, timeSlots: times)
            rooms.append(room)
        }
        return rooms
    }
}

extension GSRTimeSlot {
    convenience init(json: JSON) throws {
        guard let id = Int(json["id"].stringValue),
            let isReserved = json["reserved"].bool,
            let startStr = json["start_time"].string else {
                throw NetworkingError.jsonError
        }
        
        let startDate = try GSRTimeSlot.extractDate(from: startStr)
        let endDate = startDate.add(minutes: 30)
        self.init(roomId: id, isAvailable: !isReserved, startTime: startDate, endTime: endDate)
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
