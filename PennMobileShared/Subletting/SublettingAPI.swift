//
//  SublettingAPI.swift
//  PennMobile
//
//  Created by Jordan H on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

struct GenericErrorResponse: Decodable {
    let detail: String
}

public enum SublettingError: String, Error {
    case invalidDateString
    case alreadyExists = "Offer already exists"
}

public class SublettingAPI {
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private static let decoder = JSONDecoder(
        keyDecodingStrategy: .convertFromSnakeCase,
        dateDecodingStrategy: .iso8601
    )
    
    public static let instance = SublettingAPI()
    public let offersUrl = "https://pennmobile.org/api/sublet/offers/"
    public let favoritesUrl = "https://pennmobile.org/api/sublet/"
    public let sublettingUrl = "https://pennmobile.org/api/sublet/properties/"

    public func createSublet(subletData: SubletData, accessToken: String) async throws -> Sublet {
        guard let url = URL(string: sublettingUrl) else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "X-Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try Self.encoder.encode(subletData)
            request.httpBody = jsonData
        } catch {
            throw NetworkingError.parsingError
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
                
        let sublet = try Self.decoder.decode(Sublet.self, from: data)
        return sublet
    }

    public func destroySublet(id: Int, accessToken: String) async throws {
        let urlString = "\(sublettingUrl)\(id)/"
        guard let url = URL(string: urlString) else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "X-Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkingError.serverError
        }
    }

    public func patchSublet(id: Int, data: SubletData, accessToken: String) async throws {
        let urlString = "\(sublettingUrl)\(id)/"
        guard let url = URL(string: urlString) else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "X-Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try Self.encoder.encode(data)
            request.httpBody = jsonData
        } catch {
            throw NetworkingError.parsingError
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkingError.serverError
        }
    }

    public func getSublets(queryParameters: [String: String]? = nil, accessToken: String) async throws -> [Sublet] {
        var urlComponents = URLComponents(string: sublettingUrl)!
        
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            urlComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "X-Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let sublets = try Self.decoder.decode([Sublet].self, from: data)
        return sublets
    }
    
    public func getSubletDetails(id: Int, accessToken: String) async throws -> Sublet {
        guard let url = URL(string: "\(sublettingUrl)\(id)/") else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "X-Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let sublet = try Self.decoder.decode(Sublet.self, from: data)
        return sublet
    }
    
    public func favoriteSublet(id: Int, accessToken: String) async throws {
        guard let url = URL(string: "\(sublettingUrl)\(id)/favorites/") else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "X-Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkingError.serverError
        }
    }
    
    public func unfavoriteSublet(id: Int, accessToken: String) async throws {
        guard let url = URL(string: "\(sublettingUrl)\(id)/favorites/") else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "X-Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkingError.serverError
        }
    }
    
    public func getFavorites(accessToken: String) async throws -> [Sublet] {
        guard let url = URL(string: "\(favoritesUrl)favorites/") else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "X-Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let sublets = try Self.decoder.decode([Sublet].self, from: data)
        return sublets
    }
    
    public func getAmenities(accessToken: String) async throws -> [String] {
        guard let url = URL(string: "\(favoritesUrl)amenities/") else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "X-Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let amenities = try Self.decoder.decode([String].self, from: data)
        return amenities
    }
    
    public func getUserOffers(accessToken: String) async throws -> [SubletOffer] {
        guard let url = URL(string: "\(offersUrl)") else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "X-Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let offers = try Self.decoder.decode([SubletOffer].self, from: data)
        return offers
    }
    
    public func getSubletOffers(id: Int, accessToken: String) async throws -> [SubletOffer] {
        guard let url = URL(string: "\(sublettingUrl)\(id)/offers/") else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "X-Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let offers = try Self.decoder.decode([SubletOffer].self, from: data)
        return offers
    }
    
    public func makeOffer(offerData: SubletOfferData, id: Int, accessToken: String) async throws -> SubletOffer {
        guard let url = URL(string: "\(sublettingUrl)\(id)/offers/") else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "X-Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try Self.encoder.encode(offerData)
            request.httpBody = jsonData
        } catch {
            throw NetworkingError.parsingError
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = Self.decoder
        decoder.dateDecodingStrategy = .iso8601Full
        
        if let errorResponse = try? decoder.decode(GenericErrorResponse.self, from: data),
           let error = SublettingError(rawValue: errorResponse.detail) {
            throw error
        }
        
        let offer = try Self.decoder.decode(SubletOffer.self, from: data)
        return offer
    }
    
    public func deleteOffer(offerData: SubletOfferData, id: Int, accessToken: String) async throws {
        guard let url = URL(string: "\(sublettingUrl)\(id)/offers/") else {
            throw NetworkingError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "X-Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try Self.encoder.encode(offerData)
            request.httpBody = jsonData
        } catch {
            throw NetworkingError.parsingError
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkingError.serverError
        }
    }
}
