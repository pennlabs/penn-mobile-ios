//
//  PollsApplication.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication {
    struct Polls {
        @MainActor
        internal static func getPollsNetworkManagerId() -> String {
            #if DEBUG
            if ProcessInfo.processInfo.environment["RANDOMIZE_POLL_ID"] != nil {
                return "fake-\(UUID().uuidString)"
            }
            #endif
            
            return UIDevice.current.identifierForVendor?.uuidString ?? ""
        }
    }
}
