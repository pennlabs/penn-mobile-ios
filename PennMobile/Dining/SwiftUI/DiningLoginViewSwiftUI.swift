//
//  DiningLoginViewSwiftUI.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 1/28/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit

struct DiningLoginViewSwiftUI: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode

    var navigationViewInstance: DiningLoginNavigationView

    func makeUIViewController(context: Context) -> DiningLoginController {
        let diningLoginController = DiningLoginController()
        diningLoginController.delegate = context.coordinator
        return diningLoginController
    }

    func updateUIViewController(_ uiViewController: DiningLoginController, context: Context) {
    }

    class Coordinator: NSObject, DiningLoginControllerDelegate {
        var parent: DiningLoginViewSwiftUI

        init(_ parent: DiningLoginViewSwiftUI) {
            self.parent = parent
        }

        func dismissDiningLoginController() {
            parent.presentationMode.wrappedValue.dismiss()
            DiningViewModelSwiftUI.instance.refreshBalance()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

protocol DiningLoginControllerDelegate {
    func dismissDiningLoginController()
}
