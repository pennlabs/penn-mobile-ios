//
//  UIKit Views.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 3/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 14, *)
struct ActivityIndicatorView: UIViewRepresentable  {

    @Binding var animating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.color = .labelPrimary
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        animating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

@available(iOS 14, *)
struct LabsLoginControllerSwiftUI: UIViewControllerRepresentable {
    
    @Binding var isShowing: Bool
    @Binding var loginFailure: Bool
    var handleError: () -> Void
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let llc = LabsLoginController { (success) in
            DispatchQueue.main.async {
                self.loginCompletion(success)
            }
        }
        
        llc.handleCancel = {
            self.handleError()
        }
        
        return UINavigationController(rootViewController: llc)
    }
    
    func updateUIViewController(_ navigationController: UINavigationController, context: Context) {}
    
    fileprivate func loginCompletion(_ successful: Bool) {
        isShowing = false
        
        if successful {
            DiningViewModelSwiftUI.instance.refreshInsights()
        } else {
            loginFailure = true
        }
    }
}

@available(iOS 14, *)
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
