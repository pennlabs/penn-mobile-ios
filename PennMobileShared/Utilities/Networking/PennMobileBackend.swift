//
//  NetworkCallExecutor.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import LabsPlatformSwift

public struct PennMobileBackend {
    static let baseApiUrl: String = "https://pennmobile.org/api"
        
    static func appendedUrlString(_ append: String) -> String {
        var front: String
        if let first = append.first, first == "/" {
            front = "\(Self.baseApiUrl)\(append)"
        } else {
            front = "\(Self.baseApiUrl)/\(append)"
        }
        
        // We may add query params, so there can't be a trailing slash
        if let last = front.last, last == "/" {
            front.removeLast()
        }

        return front
    }
    
    public static func executeEndpoint<T: PennMobileEndpoint>(_ endpoint: T) async throws -> T.returns {
        let url = URL(string: Self.appendedUrlString(endpoint.path))!
        
        var request = endpoint.authenticated ? try await URLRequest(url: url, mode: .accessToken) : URLRequest(url: url)

        if let json = endpoint.bodyJSON {
            let enc: JSONEncoder = endpoint.requestBodyEncoder ?? JSONEncoder()
            request.httpBody = try enc.encode(json)
        }

        if let queryParams = endpoint.queryParams {
            let queryArray = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
            request.url?.append(queryItems: queryArray)
        }
        
        request.httpMethod = endpoint.method
        
        var (data, res) = try await URLSession.shared.data(for: request)
        guard let http = res as? HTTPURLResponse else {
            throw BackendError.unknownError(rawResponse: res)
        }
        guard (200..<300).contains(http.statusCode) else {
            switch http.statusCode {
            case 400..<500:
                throw BackendError.clientError(code: http.statusCode, response: http)
            case 500..<600:
                throw BackendError.serverError(code: http.statusCode, response: http)
            default:
                throw BackendError.unknownError(rawResponse: res)
            }
        }

        let dec = endpoint.responseDecoder ?? JSONDecoder()
        return try dec.decode(T.returns.self, from: data)
    }
}
