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

    let availUrl = "https://pennmobile.org/api/gsr/availability/"
    let locationsUrl = "https://pennmobile.org/api/gsr/locations/"
    let bookingUrl = "https://pennmobile.org/api/gsr/book/"
    let reservationURL = "https://pennmobile.org/api/gsr/reservations/"
    let cancelURL = "https://pennmobile.org/api/gsr/cancel/"

    func getLocations (completion: @escaping (Result<[GSRLocation], NetworkingError>) -> Void) {
        let url = URL(string: self.locationsUrl)!

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse, let data = data, httpResponse.statusCode == 200 {

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                do {
                    var gsrLocations = try decoder.decode([GSRLocation].self, from: data)
                    // Manually placing Huntsman as first row.
                    // TODO: use analytics to decide on orders
                    gsrLocations.sort(by: {a, b in a.gid < b.gid})
                    completion(.success(gsrLocations))
                } catch {
                    completion(.failure(.parsingError))
                }
            }
        }

        task.resume()
    }

    func getAvailability(lid: String, gid: Int, startDate: String? = nil, endDate: String? = nil, completion: @escaping (Result<[GSRRoom], NetworkingError>) -> Void) {
        OAuth2NetworkManager.instance.getAccessToken { token in
            var url = URL(string: "\(self.availUrl)")!
            url.appendPathComponent(lid)
            url.appendPathComponent("\(gid)")

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
                        let response = try decoder.decode(GSRAvailabilityAPIResponse.self, from: data)

                        completion(.success(response.rooms))
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

            let url = URL(string: self.reservationURL)!
            let request = URLRequest(url: url, accessToken: token)

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse, let data = data, httpResponse.statusCode == 200 {

                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    do {
                        let reservations = try decoder.decode([GSRReservation].self, from: data)
                        completion(.success(reservations))
                    } catch {
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
}
