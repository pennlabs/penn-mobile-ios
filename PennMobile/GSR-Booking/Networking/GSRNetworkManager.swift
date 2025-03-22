//
//  NetworkManager.swift
//  GSR
//
//  Created by Zhilei Zheng on 01/02/2018.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import Foundation
import SwiftyJSON
import PennMobileShared

class GSRNetworkManager {
    static let availUrl = "https://pennmobile.org/api/gsr/availability/"
    static let locationsUrl = "https://pennmobile.org/api/gsr/locations/"
    static let bookingUrl = "https://pennmobile.org/api/gsr/book/"
    static let reservationURL = "https://pennmobile.org/api/gsr/reservations/"
    static let cancelURL = "https://pennmobile.org/api/gsr/cancel/"
    
    static func getLocations() async throws -> [GSRLocation] {
        let url = URL(string: GSRNetworkManager.locationsUrl)!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkingError.serverError
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode([GSRLocation].self, from: data)
    }
    
    static func getAvailability(for location: GSRLocation, startDate: Date? = nil, endDate: Date? = nil) async throws -> [GSRRoom] {
        var url = URL(string: GSRNetworkManager.availUrl)!
        url.appendPathComponent(location.lid)
        url.appendPathComponent("\(location.gid)")
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "EST")!
        formatter.dateFormat = "yyyy-MM-dd"
        if let startDate {
            url.appendQueryItem(name: "start", value: formatter.string(from: startDate))
        }
        if let endDate {
            url.appendQueryItem(name: "end", value: formatter.string(from: endDate))
        }
        
        let request = try await URLRequest(url: url, mode: .accessToken)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkingError.serverError
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        let res = try decoder.decode(GSRAvailabilityAPIResponse.self, from: data)
        return res.rooms
    }
    
    static func makeBooking(for booking: GSRBooking) async throws {
        let url = URL(string: GSRNetworkManager.bookingUrl)!
        var request = try await URLRequest(url: url, mode: .accessToken)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        request.httpBody = try encoder.encode(booking)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkingError.serverError
        }
    }

    static func getReservations() async throws -> [GSRReservation] {
        let url = URL(string: GSRNetworkManager.reservationURL)!
        let request = try await URLRequest(url: url, mode: .accessToken)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkingError.serverError
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([GSRReservation].self, from: data)
    }

    static func deleteReservation(_ reservation: GSRReservation) async throws {
        let url = URL(string: GSRNetworkManager.cancelURL)!
        var request = try await URLRequest(url: url, mode: .accessToken)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: ["booking_id": reservation.bookingId])
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkingError.serverError
        }
    }
}
