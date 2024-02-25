//
//  SublettingAPI.swift
//  PennMobile
//
//  Created by Jordan H on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import PennMobileShared

struct GenericErrorResponse: Decodable {
    let detail: String
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
    
    private func makeSubletRequest<C: Encodable, R: Decodable>(_ urlStr: String? = nil, url: URL? = nil, method: String, isContentJSON: Bool = false, content: C? = nil as String?, returnType: R.Type? = nil as String.Type?, decoder: JSONDecoder? = nil) async throws -> R? {
        guard let accessToken = await OAuth2NetworkManager.instance.getAccessTokenAsync() else {
            throw NetworkingError.authenticationError
        }
        
        var urlReq = url
        if urlStr == nil && url == nil {
            throw NetworkingError.serverError
        } else if urlStr != nil {
            guard let urlVal = URL(string: urlStr!) else {
                throw NetworkingError.serverError
            }
            urlReq = urlVal
        }
        
        var request = URLRequest(url: urlReq!)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken.value)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(accessToken.value)", forHTTPHeaderField: "X-Authorization")
        if isContentJSON {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if content != nil {
            do {
                let jsonData = try Self.encoder.encode(content)
                request.httpBody = jsonData
            } catch {
                throw NetworkingError.parsingError
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if returnType != nil {
            let dataDecoder = decoder ?? Self.decoder
            if let errorResponse = try? dataDecoder.decode(GenericErrorResponse.self, from: data),
               let error = NetworkingError(rawValue: errorResponse.detail) {
                throw error
            }
        }
            
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200, httpResponse.statusCode <= 299 else {
            throw NetworkingError.serverError
        }
        
        if returnType != nil {
            return try Self.decoder.decode(returnType!, from: data)
        } else {
            return nil
        }
    }
    
    public func createSublet(subletData: SubletData) async throws -> Sublet {
        if let result = try await makeSubletRequest(sublettingUrl, method: "POST", isContentJSON: true, content: subletData, returnType: Sublet.self) {
            return result
        } else {
            throw NetworkingError.serverError
        }
    }

    public func destroySublet(id: Int) async throws {
        _ = try await makeSubletRequest("\(sublettingUrl)\(id)/", method: "DELETE")
    }

    public func patchSublet(id: Int, data: SubletData) async throws {
        _ = try await makeSubletRequest("\(sublettingUrl)\(id)/", method: "PATCH", isContentJSON: true, content: data)
    }

    public func getSublets(queryParameters: [String: String]? = nil) async throws -> [Sublet] {
        var urlComponents = URLComponents(string: sublettingUrl)!

        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            urlComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = urlComponents.url else {
            throw NetworkingError.serverError
        }
        
        if let result = try await makeSubletRequest(url: url, method: "GET", returnType: [Sublet].self) {
            return result
        } else {
            throw NetworkingError.serverError
        }
    }
    
    public func getSubletDetails(id: Int) async throws -> Sublet {
        if let result = try await makeSubletRequest("\(sublettingUrl)\(id)/", method: "GET", returnType: Sublet.self) {
            return result
        } else {
            throw NetworkingError.serverError
        }
    }
    
    public func favoriteSublet(id: Int) async throws {
        _ = try await makeSubletRequest("\(sublettingUrl)\(id)/favorites/", method: "POST")
    }
    
    public func unfavoriteSublet(id: Int) async throws {
        _ = try await makeSubletRequest("\(sublettingUrl)\(id)/favorites/", method: "DELETE")
    }
    
    public func getFavorites() async throws -> [Sublet] {
        if let result = try await makeSubletRequest("\(favoritesUrl)favorites/", method: "GET", returnType: [Sublet].self) {
            return result
        } else {
            throw NetworkingError.serverError
        }
    }
    
    public func getAmenities() async throws -> [String] {
        if let result = try await makeSubletRequest("\(favoritesUrl)amenities/", method: "GET", returnType: [String].self) {
            return result
        } else {
            throw NetworkingError.serverError
        }
    }
    
    public func getUserOffers() async throws -> [SubletOffer] {
        if let result = try await makeSubletRequest("\(offersUrl)", method: "GET", returnType: [SubletOffer].self) {
            return result
        } else {
            throw NetworkingError.serverError
        }
    }
    
    public func getSubletOffers(id: Int) async throws -> [SubletOffer] {
        if let result = try await makeSubletRequest("\(sublettingUrl)\(id)/offers/", method: "GET", returnType: [SubletOffer].self) {
            return result
        } else {
            throw NetworkingError.serverError
        }
    }
    
    public func makeOffer(offerData: SubletOfferData, id: Int) async throws -> SubletOffer {
        let decoder = Self.decoder
        decoder.dateDecodingStrategy = .iso8601Full
        
        if let result = try await makeSubletRequest("\(sublettingUrl)\(id)/offers/", method: "POST", isContentJSON: true, content: offerData, returnType: SubletOffer.self, decoder: decoder) {
            return result
        } else {
            throw NetworkingError.serverError
        }
    }
    
    public func deleteOffer(offerData: SubletOfferData, id: Int) async throws {
        _ = try await makeSubletRequest("\(sublettingUrl)\(id)/offers/", method: "DELETE", isContentJSON: true, content: offerData)
    }
}
