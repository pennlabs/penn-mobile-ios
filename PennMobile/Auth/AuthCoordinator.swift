//
//  AuthCoordinator.swift
//  PennMobile
//
//  Created by Anthony Li on 4/23/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import Foundation

enum AuthState {
    case loggingIn
    case guest
    case authenticated
}

class AuthCoordinator: ObservableObject {
    @Published var authState: AuthState
    
    init(initialAuthState: AuthState) {
        authState = initialAuthState
    }
}
