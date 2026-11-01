//
//  PennMobileNetworkCall.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import CryptoKit
import Foundation
import LabsPlatformSwift

public protocol PennMobileEndpoint: Sendable {
    var backend: EndpointBackend { get }
    var path: String { get }
    var method: EndpointRequestMethod { get }
    var authenticated: Bool { get }
    var headers: [String: String]? { get }
    var queryParams: [String: String]? { get }
    var bodyJSON: (any Encodable & Sendable)? { get }
    var bodyData: Data? { get }
    associatedtype Response: Codable
    
    var requestBodyEncoder: JSONEncoder? { get }
    var responseDecoder: JSONDecoder? { get }
    
    func errorResponse(error: BackendError) -> ToastConfiguration
}

public extension PennMobileEndpoint {
    var backend: EndpointBackend { .pennMobile }
    var method: EndpointRequestMethod { .get() }
    var authenticated: Bool { false }
    var headers: [String: String]? { nil }
    var queryParams: [String: String]? { nil }
    var bodyJSON: (any Encodable & Sendable)? { nil }
    var bodyData: Data? { nil }
    var requestBodyEncoder: JSONEncoder? { nil }
    var responseDecoder: JSONDecoder? { nil }
    
    internal var requestHashKey: String {
        let query = (queryParams ?? [:])
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
        let key = (["\(backend.rawValue)", path, "\(authenticated)"] + query).joined(separator: "\n")

        var hash = SHA256()
        hash.update(data: Data(key.utf8))
        if let bodyData {
            hash.update(data: bodyData)
        }
        if let bodyJSON {
            // Sorted so the same body always hashes the same, regardless of requestBodyEncoder
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            if let json = try? encoder.encode(bodyJSON) {
                hash.update(data: json)
            }
        }

        return hash.finalize().map { String(format: "%02x", $0) }.joined()
    }

    @discardableResult
    func execute(shouldSilentlyFail: Bool = false) async -> BackendFetchedResult<Response> {
        // The toast manager function is optional because the widget runtime never gives it a value, but the app does
        let managerDisplayToast = !shouldSilentlyFail ? await ToastPresentationManager.shared.displayToast : nil
        
        
        let value = await PennMobileBackend.executeEndpoint(self, toast: managerDisplayToast ?? { _ in })
        
        if case .get(_?) = method {
            switch value {
            case .success(let res):
                CacheManager.store(request: self, result: res)
            case .failure(.clientError):
                CacheManager.clear(request: self)
            default:
                break
            }
        }
        return value
    }
    
    func loadFromCache() -> BackendFetchedResult<Response> {
        guard let cached = CacheManager.get(request: self) else {
            return .pending
        }

        return .success(cached)
    }
}


