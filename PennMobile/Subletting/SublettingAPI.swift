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
        dateDecodingStrategy: .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = DateFormatter.iso8601.date(from: dateString) {
                return date
            } else if let date = DateFormatter.iso8601Full.date(from: dateString) {
                return date
            } else if let date = DateFormatter.yyyyMMdd.date(from: dateString) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
            }
        })
    )
    
    public static let instance = SublettingAPI()
    public let offersUrl = "https://pennmobile.org/api/sublet/offers/"
    public let favoritesUrl = "https://pennmobile.org/api/sublet/"
    public let sublettingUrl = "https://pennmobile.org/api/sublet/properties/"
    
    private func makeSubletRequest<C: Encodable, R: Decodable>(_ urlStr: String? = nil, url: URL? = nil, method: String, isContentJSON: Bool = false, content: C? = nil as String?, returnType: R.Type? = nil as String.Type?) async throws -> R? {
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
            if let errorResponse = try? Self.decoder.decode(GenericErrorResponse.self, from: data),
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
    
    public func getSubletDetails(id: Int, withOffers: Bool = true) async throws -> Sublet {
        if var result = try await makeSubletRequest("\(sublettingUrl)\(id)/", method: "GET", returnType: Sublet.self) {
            if withOffers {
                result.offers = try? await getSubletOffers(id: id)
            }
            return result
        } else {
            throw NetworkingError.serverError
        }
    }
    
    public func getSubletDetails(sublets: [Sublet], withOffers: Bool = false) async throws -> [Sublet] {
        return await withTaskGroup(of: Sublet.self) { group in
            var outputSublets: [Sublet] = []
            outputSublets.reserveCapacity(sublets.count)
            
            for sublet in sublets {
                group.addTask {
                    return (try? await self.getSubletDetails(id: sublet.id, withOffers: withOffers)) ?? sublet
                }
            }
            for await outputSublet in group {
                outputSublets.append(outputSublet)
            }
            
            return sublets
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
            return result.sorted { $0.lowercased() < $1.lowercased() }
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
        if let result = try await makeSubletRequest("\(sublettingUrl)\(id)/offers/", method: "POST", isContentJSON: true, content: offerData, returnType: SubletOffer.self) {
            return result
        } else {
            throw NetworkingError.serverError
        }
    }
    
    public func deleteOffer(offerData: SubletOfferData, id: Int) async throws {
        _ = try await makeSubletRequest("\(sublettingUrl)\(id)/offers/", method: "DELETE", isContentJSON: true, content: offerData)
    }
    
    public func getAppliedSublets() async throws -> [Sublet] {
        let offers = try await self.getUserOffers()
        
        return await withTaskGroup(of: Sublet?.self) { group in
            var sublets: [Sublet] = []
            sublets.reserveCapacity(offers.count)
            
            for offer in offers {
                group.addTask {
                    guard var sublet = try? await self.getSubletDetails(id: offer.sublet, withOffers: false) else {
                        return nil
                    }
                    sublet.offers?.append(offer) ?? (sublet.offers = [offer])
                    return sublet
                }
            }
            for await sublet in group where sublet != nil {
                sublets.append(sublet!)
            }
            
            return sublets
        }
    }
    
    public func uploadSubletImage(image: Data, id: Int) async throws {
        guard let accessToken = await OAuth2NetworkManager.instance.getAccessTokenAsync() else {
            throw NetworkingError.authenticationError
        }
        
        guard let url = URL(string: "\(sublettingUrl)\(id)/images/") else {
            throw NetworkingError.serverError
        }
        
        let boundary = MultipartBody.generateBoundary()
        let imagePart = MultipartContent(type: "image/jpeg", name: "image", data: image)
        let idPart = try MultipartContent(name: "sublet", content: "\(id)")
        let multipartBody = try MultipartBody(boundary: boundary, content: [imagePart, idPart])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken.value)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(accessToken.value)", forHTTPHeaderField: "X-Authorization")
        request.setValue(multipartBody.contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = try multipartBody.assembleData()
        
        let (_, response) = try await URLSession.shared.upload(for: request, from: request.httpBody!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200, httpResponse.statusCode <= 299 else {
            let tmp = (response as? HTTPURLResponse)!
            print(tmp.statusCode)
            throw NetworkingError.serverError
        }
    }
    
    public func uploadSubletImages(images: [Data], id: Int) async throws {
        await withTaskGroup(of: Void.self) { group in
            for image in images {
                group.addTask {
                    try? await self.uploadSubletImage(image: image, id: id)
                }
            }
            for await _ in group {
            }
        }
    }
}
