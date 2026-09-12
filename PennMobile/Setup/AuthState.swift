//
//  AuthState.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

enum AuthState: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .guest: "Guest"
        case .loggedIn: "Logged In"
        case .loggedOut: "Logged Out"
        }
    }
    
    case loggedIn, guest, loggedOut
}
