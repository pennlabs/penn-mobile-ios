//
//  DiningLogin.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/5/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI
import AuthenticationServices
import CryptoKit
import PennMobileShared

class DiningLogin {
    static let clientId = "5c09c08b240a56d22f06b46789d0528a"
    static let authorizeUrl = URL(string: "https://prod.campusexpress.upenn.edu/api/v1/oauth/authorize")!
    static let tokenUrl = URL(string: "https://prod.campusexpress.upenn.edu/api/v1/oauth/token")!

    static let redirectHost = "pennlabs.org"
    static let redirectPath = "/pennmobile/ios/campus_express_callback/"
    static var redirectUri: String { "https://\(redirectHost)\(redirectPath)" }

    enum Error: Swift.Error {
        case invalidCallback
    }

    @MainActor
    static func login(using session: WebAuthenticationSession) async throws {
        let verifier = String.randomString(length: 64)
        let state = String.randomString(length: 32)
        let challenge = Data(SHA256.hash(data: Data(verifier.utf8)))
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        var url = authorizeUrl
        url.append(queryItems: [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "scope", value: "read"),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "redirect_uri", value: redirectUri)
        ])

        let callback = try await session.authenticate(
            using: url,
            callback: .https(host: redirectHost, path: redirectPath),
            additionalHeaderFields: [:]
        )

        let params = callback.queryParameters
        guard params["state"] == state, let code = params["code"] else {
            throw Error.invalidCallback
        }

        var tokenRequest = tokenUrl
        tokenRequest.append(queryItems: [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "code_verifier", value: verifier),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: redirectUri)
        ])

        let (data, _) = try await URLSession.shared.data(from: tokenRequest)
        let token = try JSONDecoder().decode(DiningToken.self, from: data)

        KeychainAccessible.instance.saveDiningToken(token.value)
        UserDefaults.standard.setDiningTokenExpiration(token.expirationDate)
    }
}

private struct DiningLoginModifier: ViewModifier {
    @Binding var isPresented: Bool
    var onCancel: (() -> Void)?
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @EnvironmentObject private var diningAnalyticsViewModel: DiningAnalyticsViewModel

    func body(content: Content) -> some View {
        content.onChange(of: isPresented) { _, isPresented in
            guard isPresented else { return }
            Task {
                if (try? await DiningLogin.login(using: webAuthenticationSession)) != nil {
                    await DiningViewModel.instance.refreshBalance()
                    await diningAnalyticsViewModel.refresh()
                } else {
                    onCancel?()
                }
                self.isPresented = false
            }
        }
    }
}

extension View {
    func diningLogin(isPresented: Binding<Bool>, onCancel: (() -> Void)? = nil) -> some View {
        modifier(DiningLoginModifier(isPresented: isPresented, onCancel: onCancel))
    }
}
