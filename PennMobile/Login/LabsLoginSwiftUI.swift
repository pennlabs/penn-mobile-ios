//
//  PennLoginSwiftUI.swift
//  PennMobile
//
//  Created by Anthony Li on 10/14/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

/// View that presents the Penn Mobile login flow, typically used in a modal context.
struct LabsLoginView: UIViewControllerRepresentable {
    /// Callback on success or cancellation.
    ///
    /// Passed `true` if the login succeeds, or `false` if the login was cancelled.
    var onCompletion: (Bool) -> Void

    func makeUIViewController(context: Context) -> LabsLoginController {
        return LabsLoginController { success in
            context.coordinator.dispatchCompletion(success: success)
        }
    }

    func updateUIViewController(_ uiViewController: LabsLoginController, context: Context) {
        context.coordinator.parent = self
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator {
        var parent: LabsLoginView

        init(_ parent: LabsLoginView) {
            self.parent = parent
        }

        func dispatchCompletion(success: Bool) {
            parent.onCompletion(success)
        }
    }
}
