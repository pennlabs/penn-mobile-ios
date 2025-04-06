//
//  SublettingAPI.swift
//  PennMobile
//
//  Created by Jordan H on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import UIKit
import PennMobileShared

struct GenericErrorResponse: Decodable {
    let detail: String
}

class SublettingAPI {
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
    
    static let instance = SublettingAPI()
    let offersUrl = "https://pennmobile.org/api/sublet/offers/"
    let favoritesUrl = "https://pennmobile.org/api/sublet/"
    let sublettingUrl = "https://pennmobile.org/api/sublet/properties/"
    
    private func makeSubletRequest<C: Encodable, R: Decodable>(_ urlStr: String? = nil, url: URL? = nil, method: String, isContentJSON: Bool = false, content: C? = nil as String?, returnType: R.Type? = nil as String.Type?) async throws -> R? {
        guard let accessToken = try? await OAuth2NetworkManager.instance.getAccessToken() else {
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
    
    func createSublet(subletData: SubletData) async throws -> Sublet {
        if let result = try await makeSubletRequest(sublettingUrl, method: "POST", isContentJSON: true, content: subletData, returnType: Sublet.self) {
            return result
        } else {
            throw NetworkingError.serverError
        }
    }
    
    func deleteSublet(id: Int) async throws {
        _ = try await makeSubletRequest("\(sublettingUrl)\(id)/", method: "DELETE")
    }
    
    func patchSublet(id: Int, data: SubletData) async throws -> Sublet {
        if let result = try await makeSubletRequest("\(sublettingUrl)\(id)/", method: "PATCH", isContentJSON: true, content: data, returnType: Sublet.self) {
            return result
        } else {
            throw NetworkingError.serverError
        }
    }
    
    func getSublets(queryParameters: [String: String]? = nil) async throws -> [Sublet] {
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
    
    func getSubletDetails(id: Int, withOffers: Bool = true) async throws -> Sublet {
        if var result = try await makeSubletRequest("\(sublettingUrl)\(id)/", method: "GET", returnType: Sublet.self) {
            if withOffers {
                result.offers = try? await getSubletOffers(id: id)
            }
            return result
        } else {
            throw NetworkingError.serverError
        }
    }
    
    func getSubletDetails(sublets: [Sublet], withOffers: Bool = false) async throws -> [Sublet] {
        return await withTaskGroup(of: Sublet.self) { group in
            var outputSublets: [Sublet] = []
            outputSublets.reserveCapacity(sublets.count)
            
            for sublet in sublets {
                group.addTask {
                    return (try? await self.getSubletDetails(id: sublet.subletID, withOffers: withOffers)) ?? sublet
                }
            }
            for await outputSublet in group {
                outputSublets.append(outputSublet)
            }
            
            return outputSublets
        }
    }
    
    func favoriteSublet(id: Int) async throws {
        _ = try await makeSubletRequest("\(sublettingUrl)\(id)/favorites/", method: "POST")
    }
    
    func unfavoriteSublet(id: Int) async throws {
        _ = try await makeSubletRequest("\(sublettingUrl)\(id)/favorites/", method: "DELETE")
    }
    
    func getFavorites() async throws -> [Sublet] {
        if let result = try await makeSubletRequest("\(favoritesUrl)favorites/", method: "GET", returnType: [Sublet].self) {
            return result
        } else {
            throw NetworkingError.serverError
        }
    }
    
    func getAmenities() async throws -> [String] {
        if let result = try await makeSubletRequest("\(favoritesUrl)amenities/", method: "GET", returnType: [String].self) {
            return result.sorted { $0.lowercased() < $1.lowercased() }
        } else {
            throw NetworkingError.serverError
        }
    }
    
    func getUserOffers() async throws -> [SubletOffer] {
        if let result = try await makeSubletRequest("\(offersUrl)", method: "GET", returnType: [SubletOffer].self) {
            return result
        } else {
            throw NetworkingError.serverError
        }
    }
    
    func getSubletOffers(id: Int) async throws -> [SubletOffer] {
        if let result = try await makeSubletRequest("\(sublettingUrl)\(id)/offers/", method: "GET", returnType: [SubletOffer].self) {
            return result
        } else {
            throw NetworkingError.serverError
        }
    }
    
    func makeOffer(offerData: SubletOfferData, id: Int) async throws -> SubletOffer {
        if let result = try await makeSubletRequest("\(sublettingUrl)\(id)/offers/", method: "POST", isContentJSON: true, content: offerData, returnType: SubletOffer.self) {
            return result
        } else {
            throw NetworkingError.serverError
        }
    }
    
    func deleteOffer(offerData: SubletOfferData, id: Int) async throws {
        _ = try await makeSubletRequest("\(sublettingUrl)\(id)/offers/", method: "DELETE", isContentJSON: true, content: offerData)
    }
    
    func getAppliedSublets() async throws -> [Sublet] {
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
    
    func uploadSubletImages(images: [UIImage], id: Int, progressHandler: @escaping (Double) -> Void) async throws -> [SubletImage] {
        guard let accessToken = try? await OAuth2NetworkManager.instance.getAccessToken() else {
            throw NetworkingError.authenticationError
        }
        
        guard let url = URL(string: "\(sublettingUrl)\(id)/images/") else {
            throw NetworkingError.serverError
        }
        
        let multipartBody = try MultipartBody {
            try MultipartContent(name: "sublet", content: "\(id)")
            
            for (index, image) in images.enumerated() {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    MultipartContent(type: "image/jpeg", name: "images", filename: "image\(index).jpeg", data: imageData)
                }
            }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken.value)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(accessToken.value)", forHTTPHeaderField: "X-Authorization")
        request.setValue(multipartBody.contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = try multipartBody.assembleData()
        
        return try await withCheckedThrowingContinuation { continuation in
            var observation: NSKeyValueObservation?
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                defer {
                    observation?.invalidate()
                }
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let data = data else {
                    continuation.resume(throwing: NetworkingError.parsingError)
                    return
                }
                
                if let errorResponse = try? Self.decoder.decode(GenericErrorResponse.self, from: data),
                   let error = NetworkingError(rawValue: errorResponse.detail) {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200, httpResponse.statusCode <= 299 else {
                    continuation.resume(throwing: NetworkingError.serverError)
                    return
                }
                
                do {
                    let images = try Self.decoder.decode([SubletImage].self, from: data)
                    continuation.resume(returning: images)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            
            observation = task.progress.observe(\Progress.fractionCompleted) { progress, _ in
                DispatchQueue.main.async {
                    progressHandler(progress.fractionCompleted)
                }
            }
            
            task.resume()
        }
    }
    
    func deleteSubletImage(imageID: Int) async throws {
        _ = try await makeSubletRequest("\(sublettingUrl)images/\(imageID)/", method: "DELETE")
    }
    
    func deleteSubletImages(images: [SubletImage]) async throws {
        return await withTaskGroup(of: Void.self) { group in
            for image in images {
                group.addTask {
                    try? await self.deleteSubletImage(imageID: image.id)
                }
            }
            for await _ in group {}
        }
    }
}
