//
//  ScannerState.swift
//  PennMobile
//
//  Created by Anthony Li on 4/22/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import UIKit

struct ScannedTicket {
    enum InvalidReason: Error {
        case malformedTicket
        case badRequest(String)
        case notFound
    }
    
    enum Status {
        case valid(Ticket)
        case duplicate(Ticket)
        case invalid(InvalidReason)
    }
    
    var status: Status
    var scanTime: Date
}

enum ScannerState {
    case noTicket
    case loading(String)
    case scanned(ScannedTicket, String)
    case error(Error)
}

extension ScannerState {
    struct Label {
        var title: LocalizedStringKey
        var icon: String
        var background: Color
        var foreground: Color
    }
    
    var label: Label {
        switch self {
        case .noTicket:
            Label(title: "Scanning", icon: "viewfinder", background: .init(UIColor.systemBackground), foreground: .secondary)
        case .loading:
            Label(title: "Checking", icon: "ticket", background: .init(UIColor.systemBackground), foreground: .primary)
        case .scanned(let ticket, _):
            switch ticket.status {
            case .valid:
                Label(title: "Valid", icon: "checkmark.circle", background: .green, foreground: .white)
            case .duplicate:
                Label(title: "Duplicate", icon: "exclamationmark.triangle.fill", background: .yellow, foreground: .black)
            case .invalid:
                Label(title: "Invalid", icon: "hand.raised.fill", background: .red, foreground: .white)
            }
        case .error:
            Label(title: "Error", icon: "ant", background: .init(UIColor.systemBackground), foreground: .red)
        }
    }
}
