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
    static func url(for endpoint: some PennMobileEndpoint) -> URL {
        let base = endpoint.backend.baseURL
        let path = endpoint.path.hasPrefix("/") ? endpoint.path : "/\(endpoint.path)"
        return URL(string: "\(base)\(path)")!
    }
    
    public static func executeEndpoint<T: PennMobileEndpoint>(_ endpoint: T) async throws -> T.Response {
        var url = Self.url(for: endpoint)
        if let queryParams = endpoint.queryParams {
            url.append(queryItems: queryParams.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        
        var request = endpoint.authenticated ? try await URLRequest(url: url, mode: .accessToken) : URLRequest(url: url)
        request.httpMethod = endpoint.method

        if let json = endpoint.bodyJSON {
            let enc: JSONEncoder = endpoint.requestBodyEncoder ?? JSONEncoder()
            request.httpBody = try enc.encode(json)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } else if let data = endpoint.bodyData {
            request.httpBody = data
        }
        
        endpoint.headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        let (data, res) = try await URLSession.shared.data(for: request)
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
        
        if let empty = EmptyResponse() as? T.Response {
            return empty
        }

        let dec = endpoint.responseDecoder ?? JSONDecoder()
        return try dec.decode(T.Response.self, from: data)
    }
}
