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
    
    let availUrl = "https://studentlife.pennlabs.org/availability/"
    let locationsUrl = "https://studentlife.pennlabs.org/locations/"
    let bookingUrl = "https://studentlife.pennlabs.org/book/"
    let reservationURL = "https://studentlife.pennlabs.org/reservations/"
    let cancelURL = "https://studentlife.pennlabs.org/cancel/"

    var bookingRequestOutstanding = false
    
    func getLocations (completion: @escaping (Result<[GSRLocation], NetworkingError>) -> Void) {
        let url = URL(string: self.locationsUrl)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse, let data = data, httpResponse.statusCode == 200 {
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let gsrLocations = try decoder.decode([GSRLocation].self, from: data)
                    completion(.success(gsrLocations))
                } catch {
                    print(error)
                    completion(.failure(.parsingError))
                }
            }
        }
        
        task.resume()
    }
    
    func getAvailability(lid: Int, gid: Int, startDate: String? = nil, endDate: String? = nil, completion: @escaping (Result<[GSRRoom], NetworkingError>) -> Void) {
        OAuth2NetworkManager.instance.getAccessToken { token in
            var url = URL(string: "\(self.availUrl)")!
            url.appendPathComponent("\(lid)")
            
            if let startDate = startDate {
                url.appendQueryItem(name: "start", value: startDate)
            }
            
            if let endDate = endDate {
                url.appendQueryItem(name: "end", value: endDate)
            }
            
            let request = token != nil ? URLRequest(url: url, accessToken: token!) : URLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse, let data = data, httpResponse.statusCode == 200 {
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        decoder.dateDecodingStrategy = .iso8601
                        let response = try decoder.decode([GSRAvailabilityAPIResponse].self, from: data)

                        if lid == 1086 {
                            if let rooms = response.first(where: {$0.gid == gid})?.rooms {
                                completion(.success(rooms))
                            } else {
                                completion(.success([]))
                            }
                        } else {
                            if let rooms = response.first?.rooms {
                                completion(.success(rooms))
                            } else {
                                completion(.failure(.serverError))
                            }
                        }
                    } catch {
                        completion(.failure(.parsingError))
                    }
                } else {
                    completion(.failure(.serverError))
                }
            }
            
            task.resume()
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
    
    func makeBooking(for booking: GSRBooking, _ completion: @escaping (Result<Void, NetworkingError>) -> Void) {
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            let url = URL(string: self.bookingUrl)!
            var request = token != nil ? URLRequest(url: url, accessToken: token!) : URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let deviceID = getDeviceID()
            request.setValue(deviceID, forHTTPHeaderField: "X-Device-ID")
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.dateEncodingStrategy = .formatted(dateFormatter)
            
            request.httpBody = try? encoder.encode(booking)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        completion(.success(()))
                    } else {
                        completion(.failure(.serverError))
                    }
                }
            })
                        
            task.resume()
        }
    }
}

// MARK: - Get Reservatoins
extension GSRNetworkManager {
    func getReservations(_ completion: @escaping (_ reservations: Result<[GSRReservation], NetworkingError>) -> Void) {
        OAuth2NetworkManager.instance.getAccessToken { token in
            guard let token = token else {
                completion(.failure(.authenticationError))
                return
            }
            
            print(token.value)
            let url = URL(string: self.reservationURL)!
            let request = URLRequest(url: url, accessToken: token)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse, let data = data, httpResponse.statusCode == 200 {
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    do {
                        let reservations = try decoder.decode([GSRReservation].self, from: data)
                        print(reservations)
                        completion(.success(reservations))
                    } catch {
                        print(error)
                        completion(.failure(.parsingError))
                    }
                }
            }
            
            task.resume()
        }
    }
}

// MARK: - Delete Reservation
extension GSRNetworkManager {
    func deleteReservation(bookingId: String, _ completion: @escaping (Result<Void, NetworkingError>) -> Void ) {
        OAuth2NetworkManager.instance.getAccessToken { token in
            guard let token = token else {
                completion(.failure(.authenticationError))
                return
            }
            
            let url = URL(string: self.cancelURL)!
            var request = URLRequest(url: url, accessToken: token)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: ["booking_id": bookingId])
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse, data != nil, httpResponse.statusCode == 200 {
                    
                    completion(.success(()))
                } else {
                    completion(.failure(.serverError))
                }
            }
            
            task.resume()
        }
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
