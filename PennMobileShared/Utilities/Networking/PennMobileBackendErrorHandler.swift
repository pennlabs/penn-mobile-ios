//
//  PennMobileErrorHandler.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/13/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI
import LabsPlatformSwift

public struct PennMobileBackendErrorHandler {
    public let color: Color // this should be an enumerable for error type, or not even a parameter at all.
    public let message: String
}

public extension PennMobileBackendErrorHandler {
    /// Messages shared across every endpoint. Endpoints provide their own messages for client and server errors and defer to this for the rest.
    static func standard(for error: BackendError) -> PennMobileBackendErrorHandler {
        let message = switch error {
        case .clientError:
            "Unable to complete this request."
        case .serverError:
            "The server encountered an error while handling this request."
        case .platformError(let platformError):
            switch platformError {
            case .notLoggedIn:
                "You need to log in to Penn Mobile to do this."
            case .jwtNotFound:
                "Unable to verify your identity for this request."
            case .refreshUnavailable:
                "Your session needs to be refreshed, but you appear to be offline."
            case .platformNotEnabled:
                "Penn Mobile is not configured to connect to Penn Labs."
            }
        case .decodingError:
            "Unable to parse the server's response."
        case .unknownResponseError:
            "Received an unexpected response from the server."
        case .otherError(is URLError):
            "Unable to reach the server because your device may be offline."
        case .otherError:
            "An unexpected error occurred."
        }

        return PennMobileBackendErrorHandler(color: .red, message: message)
    }
}


public typealias ToastPresentationManager = @MainActor (PennMobileBackendErrorHandler) -> Void

public extension EnvironmentValues {
    @Entry var presentToast: ToastPresentationManager? = nil
}
