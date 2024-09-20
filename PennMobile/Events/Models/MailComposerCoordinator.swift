//
//  MailComposerCoordinator.swift
//  PennMobile
//
//  Created by Jacky on 3/29/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import MessageUI
import SwiftUI

// uikit for mail composing (will inject into swiftui view)
class MailComposerCoordinator: NSObject, MFMailComposeViewControllerDelegate {
    
    @Binding var isShowing: Bool
    
    var email: String
    
    init(isShowing: Binding<Bool>, email: String) {
        _isShowing = isShowing
        self.email = email
    }
    
    func makeMFMailComposeViewController() -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients([email])
        mailComposeVC.setSubject("Contact")
        
        return mailComposeVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        isShowing = false
    }
}

struct MailComposeView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    var email: String
    
    func makeCoordinator() -> MailComposerCoordinator {
        return MailComposerCoordinator(isShowing: $isShowing, email: email)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        return context.coordinator.makeMFMailComposeViewController()
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        uiViewController.setToRecipients([email])
    }
}
