//
//  ToastConfiguration.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/25/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI
import LabsPlatformSwift

public struct ToastConfiguration {
    public let id: UUID
    public let content: any View
    public let accessibilityAnnouncement: String.LocalizationValue
    
    public init(id: UUID = UUID(), @ViewBuilder _ content: () -> any View, accessibilityAnnouncement: String.LocalizationValue) {
        self.id = id
        self.content = content()
        self.accessibilityAnnouncement = accessibilityAnnouncement
    }

    public init(id: UUID = UUID(), message: String) {
        self.id = id
        let localized = String.LocalizationValue(message)
        self.content = Text(LocalizedStringResource(localized))
        self.accessibilityAnnouncement = localized
    }
    
    public func postAccessibilityAnnouncement() {
        var string = AttributedString(localized: accessibilityAnnouncement)
        AccessibilityNotification.Announcement(string)
            .post()
    }
}

public extension ToastConfiguration {
    /// Messages shared across every endpoint. Endpoints provide their own messages for client and server errors and defer to this for the rest.
    static func standard(for error: BackendError) -> ToastConfiguration {
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

        return self.init(message: message)
    }
}
