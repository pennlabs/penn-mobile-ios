//
//  GetCalendar.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/21/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Events {
    struct GetCalendar: PennMobileEndpoint {
        public typealias Response = [CalendarEvent]
        public let path = "/penndata/calendar/"

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load the university calendar.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading the university calendar right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
