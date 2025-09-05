//
//  Toasts.swift
//  PennMobile
//
//  Created by Anthony Li on 11/17/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct ToastConfiguration {
    var id: UUID
    var content: any View
    var accessibilityAnnouncement: String.LocalizationValue
    
    init(id: UUID = UUID(), @ViewBuilder _ content: () -> any View, accessibilityAnnouncement: String.LocalizationValue) {
        self.id = id
        self.content = content()
        self.accessibilityAnnouncement = accessibilityAnnouncement
    }

    init(id: UUID = UUID(), message: String.LocalizationValue) {
        self.id = id
        self.content = Text(LocalizedStringResource(message))
        self.accessibilityAnnouncement = message
    }
}

struct ToastView: View {
    var configuration: ToastConfiguration
    
    var body: some View {
        HomeCardView {
            AnyView(configuration.content)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: 480)
                .background(Color.baseRed)
                .environment(\.colorScheme, .dark)
        }
    }
}

typealias ToastPresentationCallback = (ToastConfiguration?) -> Void

private struct PresentToastKey: EnvironmentKey {
    static let defaultValue: ToastPresentationCallback = { _ in }
}

extension EnvironmentValues {
    var presentToast: ToastPresentationCallback {
        get { self[PresentToastKey.self] }
        set { self[PresentToastKey.self] = newValue }
    }
}

protocol LegacyToastPresentingViewController {
    var presentToast: ToastPresentationCallback? { get set }
}

extension UIViewController {
    func resolveToastPresentingController() -> LegacyToastPresentingViewController? {
        var next: UIViewController? = self
        
        // Try to find a LegacyToastPresentingViewController in the direct hierarchy
        while let current = next {
            if let current = current as? LegacyToastPresentingViewController {
                return current
            }
            
            next = current.parent
        }
        
        return nil
    }
    
    func present(toast: ToastConfiguration?) {
        resolveToastPresentingController()?.presentToast?(toast)
    }
}

extension ToastConfiguration {
    func postAccessibilityAnnouncement() {
        var string = AttributedString(localized: accessibilityAnnouncement)
        AccessibilityNotification.Announcement(string)
            .post()
    }
}

extension ToastConfiguration {
    static let noInternet = ToastConfiguration(message: "No Internet Connection")
    
    static let apiError = ToastConfiguration({
        VStack {
            Text("Unable to connect to the API.")
            Text("Please refresh and try again.")
        }
    }, accessibilityAnnouncement: "Unable to connect to the API. Please refresh and try again.")
    
    static let laundryDown = ToastConfiguration({
        VStack {
            Text("We're currently unable to contact Penn's laundry servers.")
            Text("We hope this will be fixed shortly.")
        }
    }, accessibilityAnnouncement: "We're currently unable to contact Penn's laundry servers. We hope this will be fixed shortly.")
}
