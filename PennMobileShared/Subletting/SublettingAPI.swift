//
//  SublettingAPI.swift
//  PennMobile
//
//  Created by Jordan H on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

public class SublettingAPI {

    public static let instance = SublettingAPI()
    public let sublettingUrl = "https://pennmobile.org/api/sublet/properties/"

    public func createSublet(subletData: SubletData) async throws -> Sublet {
        guard let url = URL(string: sublettingUrl) else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            let jsonData = try encoder.encode(subletData)
            request.httpBody = jsonData
        } catch {
            throw NetworkingError.parsingError
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let sublet = try decoder.decode(Sublet.self, from: data)
        return sublet
    }

    public func destroySublet(id: Int) async throws {
        let urlString = "\(sublettingUrl)\(id)/"
        guard let url = URL(string: urlString) else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkingError.serverError
        }
    }

    public func patchSublet(id: Int, data: SubletData) async throws {
        let urlString = "\(sublettingUrl)\(id)/"
        guard let url = URL(string: urlString) else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            let jsonData = try encoder.encode(data)
            request.httpBody = jsonData
        } catch {
            throw NetworkingError.parsingError
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkingError.serverError
        }
    }

    public func getSublets(queryParameters: [String: String]? = nil) async throws -> [Sublet] {
        var urlComponents = URLComponents(string: sublettingUrl)!
        
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            urlComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let sublets = try decoder.decode([Sublet].self, from: data)
        return sublets
    }
}
