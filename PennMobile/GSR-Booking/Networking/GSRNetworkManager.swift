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
    static let locationsUrl = "https://pennmobile.org/api/gsr/user-locations/"
    static let bookingUrl = "https://pennmobile.org/api/gsr/book/"
    static let reservationURL = "https://pennmobile.org/api/gsr/reservations/"
    static let cancelURL = "https://pennmobile.org/api/gsr/cancel/"
    static let isWhartonURL = "https://pennmobile.org/api/gsr/wharton/"
    static let groupShareURL = "https://pennmobile.org/api/gsr/share/"
    
    // deep link gsr share url format
    static let publicDeepLinkURL = "https://pennmobile.org/gsr/share"
    
    // MARK: GSR handlers
    static func getLocations() async throws -> [GSRLocation] {
        let url = URL(string: GSRNetworkManager.locationsUrl)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        let (data, response) = try await URLSession(authenticationMode: .accessToken).data(for: request)
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
        
        let (_, response) = try await URLSession.shared.data(for: request)
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
    
    static func whartonAllowed() async throws -> Bool {
        let url = URL(string: GSRNetworkManager.isWhartonURL)!
        let request = try await URLRequest(url: url, mode: .accessToken)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkingError.serverError
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let res = try decoder.decode(IsWhartonAPIResponse.self, from: data)
        return res.isWharton
    }
    
    // MARK: GSR Share network handlers
    static func getShareCodeLink(for reservation: GSRReservation) async throws -> String {
        let url = URL(string: GSRNetworkManager.groupShareURL)!
        
        var request = try await URLRequest(url: url, mode: .accessToken)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "booking_id": reservation.bookingId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        print("BODY:", String(data: data, encoding: .utf8) ?? "nil")
        print("RESPONSE:", response)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkingError.serverError
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let res = try decoder.decode(GroupShareAPIResponse.self, from: data)
        return buildShareCodeLink(shareCode: res.code)
    }
    
    static func getShareModelFromShareCode(shareCode: String) async throws -> GSRReservation {
        let url = URL(string: "\(groupShareURL)\(shareCode)")!
        let request = try await URLRequest(url: url, mode: .accessToken)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        print(String(data: data, encoding: .utf8) ?? "<non-utf8 data>")
        print(response)

        switch httpResponse.statusCode {
            case 200...299:
                break
            case 400:
                throw ShareCodeError.invalidShareCode
            case 404:
                throw ShareCodeError.shareCodeNotFoundOrExpired
            default:
                throw NetworkingError.serverError
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let res = try decoder.decode(GSRReservation.self, from: data)
        // check to make sure GSR isn't expired
        guard let isValid = res.isValid else {
            throw ShareCodeError.expiredGSR
        }
        guard isValid else {
            throw ShareCodeError.expiredGSR
        }
        return res
    }
    
    static func revokeShareCode(shareCode: String) async throws -> GSRReservation {
        let url = URL(string: "\(groupShareURL)\(shareCode)")!
        var request = try await URLRequest(url: url, mode: .accessToken)
        request.httpMethod = "DELETE"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw NetworkingError.serverError
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let res = try decoder.decode(GSRReservation.self, from: data)
        return res
    }
    
    
    static func buildShareCodeLink(shareCode: String) -> String {
        return "\(publicDeepLinkURL)?data=\(shareCode)"
    }
    
    // MARK: Decode structs
    struct IsWhartonAPIResponse: Codable {
        let isWharton: Bool
    }
    
    struct GroupShareAPIResponse: Codable {
        let code: String
    }
}

