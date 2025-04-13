//
//  LoggedOutView.swift
//  PennMobile
//
//  Created by Anthony Li on 9/17/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import LabsPlatformSwift

struct LoggedOutView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.colorScheme) var colorScheme
    @State var isPresentingLoginSheet = false
    let platform = LabsPlatform.shared

    var body: some View {
        VStack(spacing: 90) {
            Image("pennmobile")
                .resizable()
                .scaledToFit()
                .frame(width: 80)
                .shadow(radius: 1)

            VStack(spacing: 15) {
                Button("Log in with PennKey") {
                    platform?.loginWithPlatform()
                }
                .buttonStyle(LoginButtonStyle(isProminent: true))

                Button("Continue as Guest") {
                    authManager.enterGuestMode()
                }
                .buttonStyle(LoginButtonStyle(isProminent: false))
            }
            .disabled(authManager.state != .loggedOut)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            let image = Image("LoginBackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            switch colorScheme {
            case .dark:
                image
                    .colorInvert()
                    .hueRotation(.degrees(180))
                    .saturation(0.8)
                    .contrast(0.8)
            default:
                image
            }
        }
        .navigationTitle("Course Schedule")
    }
}

struct LoginButtonStyle: ButtonStyle {
    var isProminent: Bool

    var gradient: LinearGradient {
        LinearGradient(stops: [
            .init(color: Color("login1"), location: 0),
            .init(color: Color("login2"), location: 0.3),
            .init(color: Color("login3"), location: 1)
        ], startPoint: .leading, endPoint: .trailing)
    }

    func makeBody(configuration: Configuration) -> some View {
        let content = configuration.label
            .fontWeight(.medium)
            .tracking(1.1)
            .textCase(.uppercase)
            .frame(minWidth: 250, minHeight: 40)
            .opacity(configuration.isPressed ? 0.6 : 1)

        return Group {
            if isProminent {
                content
                    .colorScheme(.dark)
                    .background {
                        gradient.clipShape(.capsule).shadow(radius: 1)
                    }
            } else {
                content
                    .foregroundStyle(gradient)
                    .background {
                        Color.uiCardBackground.clipShape(.capsule).shadow(radius: 1)
                    }
                    .overlay {
                        Capsule().strokeBorder(gradient, lineWidth: 1)
                    }
            }
        }
    }
}

#Preview {
    LoggedOutView()
}
