//
//  TicketingAPI.swift
//  PennMobile
//
//  Created by Anthony Li on 4/28/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import PennMobileShared

struct TicketEvent: Decodable {
    var name: String
}

struct Ticket: Decodable {
    var id: String
    var event: TicketEvent
    var type: String
    var owner: String
    var attended: Bool
}

class TicketingAPI {
    let baseURL: String
    let decoder = JSONDecoder()
    
    static let shared = TicketingAPI(baseURL: "https://pennclubs.com")
    
    init(baseURL: String) {
        self.baseURL = baseURL
        
        decoder.dateDecodingStrategy = .iso8601
    }
    
    private func ticketUrl(forId id: String) -> URL? {
        guard let pathComponent = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        
        return URL(string: "\(baseURL)/api/tickets/\(pathComponent)")
    }
    
    func getTicket(id: String) async throws -> Ticket? {
        guard let accessToken = await OAuth2NetworkManager.instance.getAccessTokenAsync() else {
            throw NetworkingError.authenticationError
        }
        
        guard let url = ticketUrl(forId: id) else {
            return nil
        }
        
        let request = URLRequest(url: url, accessToken: accessToken)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let response = response as? HTTPURLResponse, response.statusCode == 404 {
            return nil
        }
        
        return try decoder.decode(Ticket.self, from: data)
    }
    
    @discardableResult func updateAttendance(id: String, to attended: Bool) async throws -> Ticket {
        guard let accessToken = await OAuth2NetworkManager.instance.getAccessTokenAsync() else {
            throw NetworkingError.authenticationError
        }
        
        guard let url = ticketUrl(forId: id) else {
            throw ScannedTicket.InvalidReason.notFound
        }
        
        struct AttendanceUpdateRequest: Encodable {
            var attended: Bool
        }
        
        var request = URLRequest(url: url, accessToken: accessToken)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(AttendanceUpdateRequest(attended: attended))
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let response = response as? HTTPURLResponse, response.statusCode == 400 {
            struct ErrorResponse: Decodable {
                var detail: String
            }
            
            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
            throw ScannedTicket.InvalidReason.badRequest(errorResponse.detail)
        }
        
        return try decoder.decode(Ticket.self, from: data)
    }
}
