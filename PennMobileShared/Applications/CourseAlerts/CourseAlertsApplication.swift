//
//  CourseAlertsApplication.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

public extension PennMobileApplication {
    struct CourseAlerts {
        static func csrfHeaders(_ csrfToken: String) -> [String: String] {
            [
                "Accept": "application/json",
                "Cookie": "csrftoken=\(csrfToken)",
                "X-CSRFToken": csrfToken,
                "Referer": "https://penncoursealert.com/api/"
            ]
        }
    }
}
