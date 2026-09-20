//
//  DiningLoginView.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 1/28/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit
import PennMobileShared

struct DiningLoginView: UIViewControllerRepresentable {
    var onDismiss: () -> Void
    @EnvironmentObject var diningAnalyticsViewModel: DiningAnalyticsViewModel

    func makeUIViewController(context: Context) -> DiningLoginController {
        let diningLoginController = DiningLoginController()
        diningLoginController.delegate = context.coordinator
        return diningLoginController
    }

    func updateUIViewController(_ uiViewController: DiningLoginController, context: Context) {
    }

    class Coordinator: NSObject, DiningLoginControllerDelegate {
        var parent: DiningLoginView

        init(_ parent: DiningLoginView) {
            self.parent = parent
        }

        func dismissDiningLoginController() {
            self.parent.onDismiss()
            Task.init {
                await DiningViewModel.instance.refreshBalance()
                await parent.diningAnalyticsViewModel.refresh()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

protocol DiningLoginControllerDelegate {
    func dismissDiningLoginController()
}
